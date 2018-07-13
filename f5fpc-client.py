#!/usr/bin/env python

import argparse
import binascii
import docker
import getpass
import logging
import os
import shlex
import signal
import subprocess
import sys
from distutils.spawn import find_executable


# initialize logging
logging.basicConfig(format='%(asctime)s %(levelname)s (%(name)s) %(message)s')
logger = logging.getLogger()
logger.setLevel(logging.INFO)


# initialize docker
docker_client = docker.from_env()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('host', help='VPN host')
    parser.add_argument('user', help='VPN user name')
    parser.add_argument('-n', '--network', nargs='*', dest='networks', help='Networks available via VPN in CIDR notation'
                                                                            ' (e.g. 10.0.0.0/8). Will try to set routes'
                                                                            ' (requires root privileges).')
    parser.add_argument('--debug', action='store_true')
    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)

    if os.getuid() != 0 and args.networks and len(args.networks) > 0:
        logging.warn('We need root privileges to set the network routes for you!')

    container_name = get_container_name(args.host)
    password = str(getpass.getpass('Enter your VPN password: '))

    # remove old container instance
    try:
        container = docker_client.containers.get(container_name)
        container.remove(force=True)
        container = None
        logging.debug('Removed old container instance')
    except docker.errors.NotFound:
        pass

    logging.debug('Preparing docker container...')

    container = docker_client.containers.run(
        'matthiaslohr/f5fpc',
        '/opt/idle.sh',
        privileged=True,
        name=container_name,
        detach=True,
        environment={
            'HOST': args.host,
            'USER': args.user,
            'HEXPASSWORD': binascii.hexlify(password.encode('utf8'))
        }
    )
    logging.debug('Docker container initialized')
    logging.info('Connecting to {host}...'.format(host=args.host))
    container_exec(container_name, '/opt/connect.sh')

    last_status = -255
    while True:
        status, stdout, stderr = container_exec(container_name, '/usr/local/bin/f5fpc -i')
        logging.debug('f5fpc --info returns {code}'.format(code=status))
        if status == 1 and last_status != 1:
            logging.info('Session initialized.')
        elif status == 2 and last_status != 2:
            logging.info('Logging in...')
        elif status == 5:
            logging.info('Connection established. Welcome to {host} network!'.format(host=args.host))
            break
        elif status == 7:
            logging.error('Login was denied.')
            container.stop()
            container.remove()
            return 1
        last_status = status

    inspection_result = docker.APIClient().inspect_container(container_name)
    container_ip = inspection_result['NetworkSettings']['IPAddress']
    logging.debug('Container IP: {ip}'.format(ip=container_ip))
    if args.networks:
        for network in args.networks:
            rc, stdout, stderr = route_add(network, container_ip)
            if rc == 0:
                logging.debug('Route {net} via {gw} added'.format(net=network, gw=container_ip))
            else:
                logging.error('Could not add route {net} via {gw}: {reason}'.format(
                    net=network, gw=container_ip, reason=stderr.strip())
                )
        if len(args.networks) > 0:
            logging.info('Routes added')

    # wait for signal
    def shutdown(signal, frame):
        logging.info('Shutting down...')
        if args.networks:
            for network in args.networks:
                rc, stdout, stderr = route_del(network, container_ip)
                if rc == 0:
                    logging.debug('Route {net} via {gw} removed'.format(net=network, gw=container_ip))
                else:
                    logging.error('Could not delete route {net} via {gw}: {reason}'.format(
                        net=network, gw=container_ip,reason=stderr.strip())
                    )
        container.stop()
        container.remove()
        return 0

    signal.signal(signal.SIGINT, shutdown)
    # TODO monitor connection state!
    signal.pause()


def get_container_name(host):
    return 'f5fpc_'+host


def container_exec(container, command):
    command_string = '{docker} exec -it {container} {command}'.format(docker=find_executable("docker"), container=container, command=command)
    command_splitted = shlex.split(command_string)
    logger.debug(command_splitted)
    process = subprocess.Popen(command_splitted, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    returncode = process.returncode
    return returncode, stdout, stderr


def os_exec(command):
    command_splitted = shlex.split(command)
    process = subprocess.Popen(command_splitted, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    returncode = process.returncode
    return returncode, stdout, stderr


def route_add(network, gateway):
    return os_exec('ip route add {network} via {gateway}'.format(network=network, gateway=gateway))


def route_del(network, gateway):
    return os_exec('ip route del {network} via {gateway}'.format(network=network, gateway=gateway))


if __name__ == '__main__':
    sys.exit(main())

#!/usr/bin/env python

import argparse
import docker
import getpass
import logging
import shlex
import signal
import subprocess
import sys


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
    parser.add_argument('-r', '--route', nargs='*')
    parser.add_argument('--debug', action='store_true')
    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)

    container_name = get_container_name(args.host)
    password = str(getpass.getpass('Enter your password: '))

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
        '/root/idle.sh',
        privileged=True,
        name=container_name,
        detach=True,
        environment={
            'HOST': args.host,
            'USER': args.user,
            'HEXPASSWORD': password.encode('hex')
        }
    )
    logging.debug('Docker container initialized')
    logging.info('Connecting to {host}...'.format(host=args.host))
    container_exec(container_name, '/root/connect.sh')

    last_status = -255
    while True:
        status = container_exec(container_name, '/usr/local/bin/f5fpc -i')

        if status == 5 and last_status != 5:
            logging.info('Connection established')
            break

    # TODO set routes

    # wait for signal
    def shutdown(signal, frame):
        # TODO remove routes
        container.stop()

    signal.signal(signal.SIGINT, shutdown)
    signal.pause()


def get_container_name(host):
    return 'f5fpc_'+host


def container_exec(container, command):
    command_string = '/usr/bin/docker exec -it {container} {command}'.format(container=container, command=command)
    command_splitted = shlex.split(command_string)
    logger.debug(command_splitted)
    return_code = subprocess.call(command_splitted, stdout=None)
    return return_code


if __name__ == '__main__':
    sys.exit(main())

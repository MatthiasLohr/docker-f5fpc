#!/usr/bin/env python

import argparse
import docker
import getpass
import logging
import shlex
import signal
import subprocess
import sys

logger = logging.getLogger()
logger.setLevel(logging.INFO)

docker_client = docker.from_env()
container = None

def main():
    global container

    parser = argparse.ArgumentParser()
    parser.add_argument('--debug', action='store_true')
    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)

    # prepare container
    host = raw_input('Enter your VPN host: ')
    container_name = get_container_name(host)

    try:
        container = docker_client.containers.get(container_name)
        logging.info('Reusing existing container...')
        container.start()
    except docker.errors.NotFound:
        logging.info('Creating new container...')
        user = str(raw_input('Enter your user name: '))
        password = str(getpass.getpass('Enter your password: '))
        container = docker_client.containers.run(
            'matthiaslohr/f5fpc',
            '/root/idle.sh',
            privileged=True,
            name=container_name,
            detach=True,
            environment={
                'HOST': host,
                'USER': user,
                'HEXPASSWORD': password.encode('hex')
            }
        )
        logging.info('Setting up VPN client...')
        container.exec_run('/root/setup.sh')
        logging.info('Setup complete')

    logger.info('Connecting to VPN...')
    container_exec(container_name, '/root/connect.sh')
    while True:
        status = container_exec(container_name, '/usr/local/bin/f5fpc -i')
        print(status)


def get_container_name(host):
    return 'f5fpc_'+host


def container_exec(container, command):
    command_string = '/usr/bin/docker exec -it {container} {command}'.format(container=container, command=command)
    command_splitted = shlex.split(command_string)
    logger.debug(command_splitted)
    return_code = subprocess.call(command_splitted)
    return return_code


def shutdown(signal, frame):
    timeout = 30
    logging.debug('Current container state: ' + container.status)
    logging.info('Shutting down (timeout in {n} seconds)...'.format(n=timeout))
    if container:
        container.reload()
        if container.status in ('created', 'running'):
            container.stop(timeout=timeout)
    logging.info('Shutdown complete')
    sys.exit(0)


if __name__ == '__main__':
    signal.signal(signal.SIGINT, shutdown)
    sys.exit(main())

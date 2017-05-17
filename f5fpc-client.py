#!/usr/bin/env python

import getpass
import signal
import subprocess
import sys
import time

def main():
	host = raw_input('Enter your VPN host: ')
	user = raw_input('Enter your user name: ')
	password = getpass.getpass('Enter your password: ')
	subprocess.call(
		[
			'docker', 'run',
			'-e', 'USER='+user,
			'-e', 'HEXPASSWORD='+str(password).encode("hex"),
			'-e', 'HOST='+host,
			'--name', 'f5fpc',
			'--privileged',
			'--rm',
			'-d',
			'matthiaslohr/f5fpc',
			'/root/connect.sh'
		]
	)
	container_ip = get_container_ip()
	subprocess.call('/sbin/route add -net 10.0.0.0/8 gw '+container_ip, shell=True)
	time.sleep(10)
	while True:
		time.sleep(1)

def docker_exec(container, command):
	p = subprocess.Popen(['docker', 'exec', container, '/bin/bash -c "{cmd}"'.format(cmd=command)], stdout=subprocess.PIPE)
	out, err = p.communicate()
	return out


def shutdown(signal, frame):
	container_ip = get_container_ip()
	subprocess.call('/usr/bin/docker kill f5fpc', shell=True)
	subprocess.call('/sbin/route del -net 10.0.0.0/8 gw '+container_ip, shell=True)
	sys.exit(0)

def get_container_ip():
	p = subprocess.Popen('/usr/bin/docker inspect --format "{{ .NetworkSettings.IPAddress }}" f5fpc', shell=True, stdout=subprocess.PIPE)
	out, err = p.communicate()
	return out


if __name__ == '__main__':
	signal.signal(signal.SIGINT, shutdown)
	sys.exit(main())

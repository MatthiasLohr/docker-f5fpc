#!/bin/bash

if [ -z "$HOST" ] ; then
	echo "HOST environment variable not set. Exiting."
	exit 1
fi

if [ ! -e "/usr/local/bin/f5fpc" ] ; then
	echo "Downloading and installing VPN client..."
	cwd=$(pwd)
	mkdir -p /tmp/f5fpc
	cd /tmp/f5fpc
	wget --no-check-certificate "https://$HOST/public/download/linux_sslvpn.tgz"
	tar xfz linux_sslvpn.tgz
	yes "yes" | ./Install.sh
	rm -rf /tmp/f5fpc
fi

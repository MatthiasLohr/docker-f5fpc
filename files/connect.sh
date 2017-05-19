#!/bin/bash

F5FPC=/usr/local/bin/f5fpc

if [ -z "$HOST" ] ; then
	echo -n "Please enter VPN host name: "
	read HOST
fi

if [ ! -f "$F5FPC" ] ; then
	echo "Downloading and installing VPN client..."
	cwd=$(pwd)
	mkdir -p /root/f5fpc
	cd /root/f5fpc
	wget --no-check-certificate https://$HOST/public/download/linux_sslvpn.tgz
	tar xfz linux_sslvpn.tgz
	yes "yes" | ./Install.sh
	rm -rf /root/f5fpc
fi

command="$F5FPC -s -x -t $HOST"

if [ -n "$USER" ] ; then
	command="$command -u $USER"
fi

if [ -n "$PASSWORD" ] ; then
	command="$command -p $PASSWORD"
fi

if [ -n "$HEXPASSWORD" ] ; then
	command="$command -P $HEXPASSWORD"
fi

$command

sysctl -w net.ipv4.ip_forward=1 > /dev/null
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

old_status=0
while true ; do
	status=$($F5FPC -i > /dev/null; echo $?)
	case $status in
		0)

		;;
		2)
		if [ "$old_status" != 2 ] ; then
			echo "Logging in..."
		fi
		;;
		3)
		if [ "$old_status" != 3 ] ; then
			echo "Logged in."
		fi
		;;
		4)
		if [ "$old_status" != 4 ] ; then
			echo "Connecting..."
		fi
		;;
		5)
		if [ "$old_status" != 5 ] ; then
			echo "Connection established."
			while [ ! -f "/etc/resolv.conf.fp-tmp" ] ; do sleep 1 ; done
			echo "/etc/resolv.conf:"
			cat /etc/resolv.conf.fp-tmp
		fi
		;;
		7)
			echo "Login denied. Exiting."
			exit 1
		;;
	esac
	
	if [ -n "$DEBUG" ] ; then
		echo old: $old_status, new: $status
	fi

	old_status=$status
done

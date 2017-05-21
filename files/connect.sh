#!/bin/bash

F5FPC=/usr/local/bin/f5fpc

if [ -z "$HOST" ] ; then
	echo -n "Please enter VPN host name (e.g. vpn.yourserver.com): "
	read HOST
fi

if [ ! -e "$F5FPC" ] ; then
	HOST=$HOST /root/setup.sh
	if [ "$?" != "0" ] ; then
		exit 1
	fi
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

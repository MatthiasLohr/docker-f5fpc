#!/bin/bash

F5FPC=/usr/local/bin/f5fpc


command="$F5FPC -s -x"

if [ -n "$HOST" ] ; then
	command="$command -t $HOST"
fi

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

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

sleep 1d

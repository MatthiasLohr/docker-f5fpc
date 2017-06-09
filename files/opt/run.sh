#!/bin/bash

F5FPC=/usr/local/bin/f5fpc

/opt/connect.sh

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

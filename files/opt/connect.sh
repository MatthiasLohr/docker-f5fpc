#!/bin/bash

F5FPC=/usr/local/bin/f5fpc

# read CLI parameters
POSITIONAL=()
while [ $# -gt 0 ] ; do
        case $1 in
                -t|--hostname)
                        VPNHOST="$2"
                        shift
                        shift
                        ;;
		-u|--user)
			USERNAME="$2"
			shift
			shift
			;;
		-p|--password)
			PASSWORD="$2"
			shift
			shift
			;;
		-P|--hex-password)
			HEXPASSWORD="$2"
			shift
			shift
			;;
                *)
                        echo "Unknown parameter!"
			exit 1
                        ;;
        esac
done

# check for all parameters
if [ -z "$VPNHOST" ] ; then
	echo -n "Please enter VPN host name (e.g. vpn.yourserver.com): "
	read VPNHOST
fi

if [ -z "$USERNAME" ] ; then
	echo -n "Please enter your VPN username: "
	read USERNAME
fi

if [ -z "$PASSWORD" -a -z "$HEXPASSWORD" ] ; then
	echo -n "Please enter your VPN password: "
	read -s PASSWORD
	echo ""
fi

# build command
command="$F5FPC -s -t $VPNHOST -u $USERNAME"

if [ -n "$PASSWORD" ] ; then
	command="$command -p $PASSWORD"
fi

if [ -n "$HEXPASSWORD" ] ; then
	command="$command -P $HEXPASSWORD"
fi

nohup $command > /dev/null

iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE


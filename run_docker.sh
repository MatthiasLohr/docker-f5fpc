#!/bin/bash

open -a xquartz

IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $IP

docker run \
	--net host \
	-it --rm --privileged \
	-e USER=$USER \
	-e DISPLAY=$IP:0 \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e QT_X11_NO_MITSHM=1 \
	-v /$HOME:/home/$USER \
	f5fpc_vpn /bin/bash


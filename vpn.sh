#!/bin/bash

echo Enter VPN server:
read vpnserver
f5fpc -s -t $vpnserver


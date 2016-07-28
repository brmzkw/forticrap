#!/bin/sh

VPN_SERVER=
VPN_USER=
VPN_PASSWORD=

mknod /dev/ppp c 108 0

eth0_net=$(ip a | grep eth0 | grep inet | awk '{print $2}')

iptables -t nat -A POSTROUTING -s "$eth0_net" -j MASQUERADE

expect -c '
set timeout -1
spawn /opt/forticlient-sslvpn/64bit/forticlientsslvpn_cli --server "'${VPN_SERVER}'" --vpnuser "'${VPN_USER}'" --keepalive

expect "Password for VPN:"
send "'${VPN_PASSWORD}'\n"

expect "Would you like to connect to this server?"
send Y\n
expect eof
'

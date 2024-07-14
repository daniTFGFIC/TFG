#! /bin/bash

if [ $# -lt 2 ]
then
    echo "The number of arguments is invalid. You need to specify two Interface names, one for AP and other connected to internet. In that order."
    exit
fi

systemctl stop isc-dhcp-server
systemctl stop hostapd.service

iptables -t nat -D POSTROUTING -o $2 -j MASQUERADE
iptables -D FORWARD -i $1 -o $2 -j ACCEPT

ip address delete 192.168.101.1/24 dev $1

ip link set $1 down

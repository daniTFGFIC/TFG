#! /bin/bash

systemctl stop isc-dhcp-server
systemctl stop hostapd.service

#iptables -t nat -D POSTROUTING -o enp1s0 -j MASQUERADE
#iptables -D FORWARD -i wlx002719b8dec1 -o enp1s0 -j ACCEPT

iptables -t nat -D POSTROUTING -o wlp0s20f3 -j MASQUERADE
iptables -D FORWARD -i wlx002719b8dec1 -o wlp0s20f3 -j ACCEPT

ip address delete 192.168.10.1/24 dev wlx002719b8dec1

ip link set wlx002719b8dec1 down

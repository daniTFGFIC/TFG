#! /bin/bash

#Instalacion
apt-get update
apt-get -y install isc-dhcp-server hostapd
pip3 install scapy

#Modificacions
systemctl unmask hostapd
systemctl disable hostapd
systemctl disable isc-dhcp-server
cat "isc_conf.txt" >> "/etc/dhcp/dhcpd.conf"

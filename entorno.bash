#! /bin/bash

#Instalacion
sudo apt-get update
sudo apt-get -y install isc-dhcp-server hostapd
pip3 install --user scapy

#Modificacions
sudo systemctl unmask hostapd
sudo systemctl disable hostapd
sudo systemctl disable isc-dhcp-server

#! /bin/bash

if [ $# -lt 2 ]
then
    echo "The number of arguments is invalid. You need to specify two Interface names, one for AP and other connected to internet. In that order."
    exit
fi

sed -i "s/^INTERFACESv4=\".*\"/INTERFACESv4=\"$1\"/" "/etc/default/isc-dhcp-server"

systemctl restart hostapd
systemctl restart isc-dhcp-server

## An IP address is assigned to the interface because hostapd does not configure it (that is why we use a DHCP server).
ip address add 192.168.101.1/24 dev $1

## NAT
# Everything that exits the interface will have an IP change.
sudo iptables -t nat -A POSTROUTING -o $2 -j MASQUERADE

# Everything that enters through the interface with address 192.168.10.1/24 will be sent through the interface connected to the internet.
sudo iptables -A FORWARD -i $1 -o $2 -j ACCEPT

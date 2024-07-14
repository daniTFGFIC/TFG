#! /bin/bash

if [ $# -lt 2 ]
then
    echo "The number of arguments is invalid. You need to specify two Interface names, one for AP and other connected to internet. In that order."
    exit
fi

systemctl restart hostapd
systemctl restart isc-dhcp-server

## Asignamos unha ip a wlx002719b8dec1 pois hostapd non configura nada diso (por eso usamos un servidor dhcp)
ip address add 192.168.101.1/24 dev $1

## NAT
# Todo o que sala de wlp0s20f3 faremos un cambio de IP
sudo iptables -t nat -A POSTROUTING -o $2 -j MASQUERADE

# Todo o que entre por wlx002719b8dec1 con dirección 192.168.10.1/24 enviarémolo por wlp0s20f3
sudo iptables -A FORWARD -i $1 -o $2 -j ACCEPT

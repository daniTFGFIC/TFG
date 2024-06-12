#! /bin/bash

#apt-get update
#apt-get -y install isc-dhcp-server hostapd

### configuracion ficheros


####


#systemctl unmask hostapd
#systemctl disable isc-dhcp-server
#systemctl disable hostapd

systemctl restart hostapd
systemctl restart isc-dhcp-server

## Asignamos unha ip a wlx002719b8dec1 pois hostapd non configura nada diso (por eso usamos un servidor dhcp)
ip address add 192.168.10.1/24 dev wlx002719b8dec1

## NAT
# Todo o que sala de wlp0s20f3 faremos un cambio de IP
sudo iptables -t nat -A POSTROUTING -o wlp0s20f3 -j MASQUERADE
#sudo iptables -t nat -A POSTROUTING -o enp1s0 -j MASQUERADE

# Todo o que entre por wlx002719b8dec1 con dirección 192.168.10.1/24 enviarémolo por wlp0s20f3
sudo iptables -A FORWARD -i wlx002719b8dec1 -o wlp0s20f3 -j ACCEPT
#sudo iptables -A FORWARD -i wlx002719b8dec1 -o enp1s0 -j ACCEPT

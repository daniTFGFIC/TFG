#! /bin/bash

if [ $# -lt 1 ]
then
    echo "Numero de argumentos inválido, se necesita el nombre de la interfaz"
    exit 1
fi

interfaz=$1
mac_suplantada=$(ip a | grep permad | awk '{print $NF}')

ip link set $interfaz down
if [ -n "$mac_suplantada" ]
then
    ip link set $interfaz addr $mac_suplantada
fi
iwconfig $interfaz mode manage
ip link set $interfaz up
sudo nmcli device set $interfaz managed yes

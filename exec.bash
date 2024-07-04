### Script principal que lanzará todos los procesos y configuraciones necesarias para el correcto funcionamiento de la herramienta ###
#! /bin/bash

if [ $# -lt 1 ]
then
    echo "Número de argumentos inválido, necesítase o nome da interfaz"
    exit 1
fi

redes_disponibles=$(python3 extract_info.py)
interfaz=$1

SSIDs=()
BSSIDs=()
PSKs=()
contador=0
current_mac=$(ip a | grep -i $interfaz -A 1 | grep "link" | awk '{print $2}')
sub_mac="${current_mac:0:14}"

while IFS= read -r red; do
    SSID=$(echo "$red" | grep -o '\bSSID: [^,]*' | cut -d ' ' -f 2-)
    BSSID=$(echo "$red" | grep -o '\bBSSID: [^,]*' | cut -d ' ' -f 2-)
    PSK=$(echo "$red" | grep -o '\bPSK: .*' | cut -d ' ' -f 2-)

    if [ "$BSSID" = "no_stored" ]
    then
        #De esta forma es posible relacionar unequivocamente cada mac con un ssid específico
        BSSID=$(printf "%s:%02x" "$sub_mac" $contador)
    fi

    # Almacenar datos en los arrays
    SSIDs+=("$SSID")
    BSSIDs+=("$BSSID")
    PSKs+=("$PSK")
    ((contador++))
done <<< "$redes_disponibles"

#Pasamos a modo monitor
nmcli device set $interfaz managed no
ip link set $interfaz down
iwconfig $interfaz mode monitor
ip link set $interfaz up

#Inicializamos archivo de log y recopilacion
rm responses.log 2>/dev/null
rm results.txt 2>/dev/null

#Lanzamos main.py para comenzar el proceso de captura/inyeccion de paquetes
python3 main.py $interfaz "${SSIDs[@]}" "${BSSIDs[@]}"

#Hacemos una pausa por si queda alguna trama aún por recivir
sleep 1

bash restore.bash $interfaz

#Gardamos só as entradas únicas
sort responses.log | uniq > results.txt

echo "SSIDs search process finishid, you can see all coincidences in results.txt file. Also you can see all responses in responses.log file"

read -p "Choose SSID to spoof: " spoofSSID

echo $spoofSSID

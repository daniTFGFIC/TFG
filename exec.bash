### Script principal que lanzará todos los procesos y configuraciones necesarias para el correcto funcionamiento de la herramienta ###
#! /bin/bash

if [ $# -lt 1 ]
then
    echo "The number of arguments is invalid, the interface name is required. The available ones are: "
    iw dev | grep Interface | awk '{print $2}'
    exit 1
fi

redes_disponibles=$(python3 extract_info.py)
interfaz=$1

separador="---------------------------\n"

SSIDs=()
BSSIDs=()
PSKs=()
contador=0
mac_actual=$(ip a | grep -i $interfaz -A 1 | grep "link" | awk '{print $2}')
sub_mac="${mac_actual:0:14}"

echo "Available SSIDs: "
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

    echo $SSID
done <<< "$redes_disponibles"

echo -e $separador

while true; do
    read -p  "Start network scan?[Y/N] " opcion

    case $opcion in
        [Yy]* )
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

            #Gardamos só as entradas únicas
            sort responses.log | uniq > results.txt

            #Deshacemos el cambio de modo monitor
            ip link set $interfaz down
            iwconfig $interfaz mode manage
            nmcli device set $interfaz managed yes
            ip link set $interfaz up

            echo "SSIDs search process finishid, you can see all coincidences in results.txt file. Also you can see all responses in responses.log file"
            break
            ;;
        [Nn]* )
            break
            ;;
        * )
            echo "Type Y/y to scan or N/n to continue"
            ;;
    esac
done

echo -e $separador

read -p "Choose SSID to spoof: " SSID_elegido

ssids_comas=$(IFS=,; echo "${SSIDs[*]}")

if [[ ! ",${ssids_comas[@]}," =~ ",${SSID_elegido}," ]]; then
    echo "SSID not found"
    exit
fi

echo "Fake AP created and runnning"

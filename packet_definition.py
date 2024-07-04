#### En este script se definirán los campos del paquete ####
from scapy.all import Dot11Elt

def get_ssid(ssid):
    return Dot11Elt(ID='SSID', info=ssid)

def get_supported_rates(trans_rates = bytes([0x82, 0x84, 0x8b, 0x96, 0x24, 0x30, 0x48, 0x6c])):
    return Dot11Elt(ID='Supported Rates', info=trans_rates)

def get_channel(channel=1):
    return Dot11Elt(ID='DSSS Set', info=chr(channel))

def get_capabilities_information(cap_val = 4352):
    #capabilities_information = "0x0011" que traducido a entero es 4352
    return cap_val

def get_erp_info(erp_info = b'\x02'):
    return Dot11Elt(ID='ERPinfo', info=erp_info)

def get_rsn_info():
    return Dot11Elt(ID="RSNinfo", info=(
        b"\x01\x00"  # RSN Version 1
        b"\x00\x0f\xac\x04"  # Group Cipher Suite: AES CCMP (CCM)
        b"\x01\x00"  # 1 Pairwise Cipher Suite count
        b"\x00\x0f\xac\x04"  # Pairwise Cipher Suite List: AES CCMP
        b"\x01\x00"  # 1 Authentication Key Management Suite (AKM) count
        b"\x00\x0f\xac\x02"  # Auth Key Management Suite List: 802.11 PSK
        b"\x0c\x00"  # RSN capabilities (WPA2 capabilities)
    ))

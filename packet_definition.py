#### In this script the package fields are defined ####
from scapy.all import Dot11Elt

def get_ssid(ssid):
    return Dot11Elt(ID='SSID', info=ssid)

def get_supported_rates():
    trans_rates = bytes([0x82, 0x84, 0x8b, 0x96, 0x0c, 0x12, 0x18, 0x24])
    return Dot11Elt(ID='Supported Rates', info=trans_rates)

def get_extended_supported_rates():
    trans_rates = bytes([0x30, 0x48, 0x60, 0x6c])
    return Dot11Elt(ID='Extended Supported Rates', info=trans_rates)

def get_channel():
    channel = 1
    return Dot11Elt(ID='DSSS Set', info=chr(channel))

def get_capabilities_information():
    cap_val = 4352
    #capabilities_information = "0x0011" que traducido a entero es 4352
    return cap_val

def get_erp_info():
    erp_info = b'\x02'
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

def get_ht_capabilities():
    ht_cap = (
        b"\x0c\x00"  # HT Capabilities Info (0x000c en little-endian)
        b"\x1b"  # A-MPDU Parameters
        b"\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"  # Supported MCS Set
        b"\x00\x00"  # HT Extended Capabilities
        b"\x00\x00\x00\x00"  # Transmit Beamforming Capabilities
        b"\x00"  # Antenna Selection Capabilities
    )
    return Dot11Elt(ID='HT Capabilities', info=ht_cap)

def get_ht_information():
    ht_info = (
        b"\x01"  # Primary Channel
        b"\x00"  # HT Information Subset 1
        b"\x00"  # HT Information Subset 2
        b"\x00\x00"  # HT Information Subset 3
        b"\x00\x00"  # RX Supported Modulation and Coding Scheme Set (Basic MCS Set)
        b"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"  # Remaining bytes to make up 22 bytes in total
    )
    return Dot11Elt(ID='HT Operation', info=ht_info) #In scapy is called Operation but is HT Information
#    return Dot11Elt(ID=61, info=ht_info)

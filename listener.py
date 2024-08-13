from scapy.all import *
import packet_definition as pd

caps = pd.get_capabilities_information()
dot_rates = pd.get_supported_rates()
dot_ext_rates = pd.get_extended_supported_rates()
dot_channel = pd.get_channel()
dot_erp = pd.get_erp_info()
dot_rsn = pd.get_rsn_info()
dot_ht_cap = pd.get_ht_capabilities()
dot_ht_inf = pd.get_ht_information()
dot_ext_caps = pd.get_ext_caps()

def handle_packet(packet, shared_data, interface):
    ssids = shared_data['ssids']
    macs = shared_data['macs']
    if packet.haslayer(Dot11ProbeReq):
        ssid = shared_data['ssid']
        mac = shared_data['mac']
        client_mac = packet.addr2.lower()
        ap_mac = packet.addr1.lower()

        if ap_mac == "ff:ff:ff:ff:ff:ff":
            dot_ssid = pd.get_ssid(ssid)

            dot11 = Dot11(type=0, subtype=5, addr1=client_mac, addr2=mac, addr3=mac)
            beacon = Dot11ProbeResp(cap=caps)
            frame = RadioTap()/dot11/beacon/dot_ssid/dot_rates/dot_ext_rates/dot_channel/dot_erp/dot_rsn/dot_ht_cap/dot_ht_inf/dot_ext_caps

            sendp(packet, iface=interface, count=1, inter=0.1, verbose=False)
        else:
            ssid_packet = packet.info.decode()
            if ssid_packet in ssids:
                with open("responses.log", 'a') as file:
                    file.write(f"Packet: Probe Request -- From: {client_mac} -- To: {ap_mac} -- SSID: {ssid_packet}\n")

    elif packet.haslayer(Dot11Auth) and packet[Dot11Auth].seqnum == 1: #client Authentication in response to the probe response.
        client_mac = packet.addr2.lower()
        ap_mac = packet.addr1.lower()
        if ap_mac in macs:
            ssid_packet = ssids[macs.index(ap_mac)]
            with open("responses.log", 'a') as file:
                file.write(f"Packet: Authentication -- From: {client_mac} -- To {ap_mac} -- SSID: {ssid_packet}\n")

def listen_for_requests(shared_data, interface, stop_event):
    def stop_sniffing(packet):
        return stop_event.is_set()
    sniff(iface=interface, prn=lambda x: handle_packet(x, shared_data, interface), stop_filter=stop_sniffing)

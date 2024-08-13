from multiprocessing import Process, Manager, Event
from scapy.layers.dot11 import RadioTap, Dot11,  Dot11Beacon, sendp
import listener as ltnr
import packet_definition as pd
import time
import sys

def main():
    interface = sys.argv[1]
    argc = len(sys.argv)
    punto_corte = argc//2+1

    # SSIDS and MACS list
    ssids = sys.argv[2:punto_corte]
    macs = sys.argv[punto_corte:]

    caps = pd.get_capabilities_information()
    dot_rates = pd.get_supported_rates()
    dot_ext_rates = pd.get_extended_supported_rates()
    dot_channel = pd.get_channel()
    dot_erp = pd.get_erp_info()
    dot_rsn = pd.get_rsn_info()
    dot_ht_cap = pd.get_ht_capabilities()
    dot_ht_inf = pd.get_ht_information()
    dot_ext_caps = pd.get_ext_caps()

    with Manager() as manager:
        shared_data = manager.dict()
        stop_event = Event()

        shared_data['ssids'] = ssids
        shared_data['macs'] = macs

        # The probe request listening process is started.
        listen_process = Process(target=ltnr.listen_for_requests, args=(shared_data, interface, stop_event))
        listen_process.start()

        # The beacon sending process is initiated within the loop.
        for ssid, mac in zip(ssids, macs):
            shared_data['ssid'] = ssid
            shared_data['mac'] = mac

            print(f"Inyectando y escuchando para SSID: \"{ssid}\"", flush=True)

            dot_ssid = pd.get_ssid(ssid)
            dot11 = Dot11(type=0, subtype=8, addr1="ff:ff:ff:ff:ff:ff", addr2=mac, addr3=mac)
            beacon = Dot11Beacon(cap=caps)
            frame = RadioTap()/dot11/beacon/dot_ssid/dot_rates/dot_ext_rates/dot_channel/dot_erp/dot_rsn/dot_ht_cap/dot_ht_inf/dot_ext_caps

            sendp(frame, iface=interface, count=300, inter=0.1, verbose=False)
            time.sleep(3)  # Waits before switching to the next SSID/MAC.

        stop_event.set()
        listen_process.join()

if __name__ == "__main__":
    main()

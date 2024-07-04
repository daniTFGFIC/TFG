from multiprocessing import Process, Manager, Event
from scapy.layers.dot11 import RadioTap, Dot11,  Dot11Beacon, sendp
import probe_listener as pl
import packet_definition as pd
import time
import sys

def main():
    interface = sys.argv[1]
    argc = len(sys.argv)
    punto_corte = argc//2+1

    #Lista de SSIDS y MACS
    ssids = sys.argv[2:punto_corte]
    macs = sys.argv[punto_corte:]

    caps = pd.get_capabilities_information()
    dot_rates = pd.get_supported_rates()
    dot_channel = pd.get_channel()
    dot_erp = pd.get_erp_info()
    dot_rsn = pd.get_rsn_info()

    with Manager() as manager:
        shared_data = manager.dict()
        stop_event = Event()

        shared_data['ssids'] = ssids
        shared_data['macs'] = macs

        # Inicia el proceso de escucha de probe requests
        listen_process = Process(target=pl.listen_for_requests, args=(shared_data, interface, stop_event))
        listen_process.start()

        # Proceso de envío de beacons dentro del bucle
        for ssid, mac in zip(ssids, macs):
            shared_data['ssid'] = ssid
            shared_data['mac'] = mac

            print(f"Inyectando y escuchando para SSID: \"{ssid}\"", flush=True)

            dot_ssid = pd.get_ssid(ssid)
            dot11 = Dot11(type=0, subtype=8, addr1="ff:ff:ff:ff:ff:ff", addr2=mac, addr3=mac)
            beacon = Dot11Beacon(cap=caps)
            frame = RadioTap()/dot11/beacon/dot_ssid/dot_rates/dot_channel/dot_erp/dot_rsn

            sendp(frame, iface=interface, count=250, inter=0.1, verbose=False)
            time.sleep(2)  # Espera antes de cambiar al siguiente SSID/MAC

        stop_event.set()
        listen_process.join()

if __name__ == "__main__":
    main()

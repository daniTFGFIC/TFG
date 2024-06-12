import signal
import time
from scapy.all import *


def signal_handler(sig, frame):
    sys.exit(0)

def handle_packet(packet):
    # Verificar si es un Probe Request
    try:
        if packet.haslayer(Dot11ProbeReq):
            # Obtener el SSID del paquete, si está presente
            ssid = packet.info.decode() if packet.info else None

            # Checar si el SSID del paquete coincide con el deseado
            if ssid in ssids:
                smac = packet.addr2
                bssid = packet.addr3
                dmac = packet.addr1
                print(f"Trama Probe Request recibida desde dispositivo '{smac}' al SSID '{ssid}' con BSSID '{bssid}' y mac destino '{dmac}'")
    except Exception as e:
        print(f"Error al procesar el paquete: {e}")

def start_sniffing(interface):
        sniff(iface=interfaz, prn=handle_packet, store=False)

if __name__ == "__main__":
    # Registrar manejadores de señales para una terminación limpia
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    interfaz = sys.argv[1]
    ssids = sys.argv[2:]
    print(f"Escuchando en la interfaz {interfaz} por tramas Probe Request dirigidas a: \n{ssids}")

    start_sniffing(interfaz)

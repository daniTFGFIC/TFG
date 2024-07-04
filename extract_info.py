import os
import configparser


wifis_path = '/etc/NetworkManager/system-connections/'

config = configparser.ConfigParser()

networks = {}

for filename in os.listdir(wifis_path):
    if filename.endswith('.nmconnection'):
        file_path = os.path.join(wifis_path, filename)
        config = configparser.ConfigParser()
        config.read(file_path)

    if config.has_section('wifi') and config.get('wifi', 'mode', fallback='') == 'infrastructure':
        ssid = config.get('wifi', 'ssid', fallback=False)
        psk = config.get('wifi-security', 'psk', fallback=False)

        bssids = config.get('wifi', 'seen-bssids', fallback=False)
        bssid = bssids.split(';')[0] if bssids else 'no_stored'

        if ssid and psk and bssid:
            networks[(ssid, bssid)] = psk

for (ssid, bssid), psk in networks.items():
    print(f'SSID: {ssid}, BSSID: {bssid}, PSK: {psk}')

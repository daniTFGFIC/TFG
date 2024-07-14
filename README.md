# TFG
## Estudo da reconexión automática a redes Wi-Fi como porta de entrada a ataques de suplantación.
Respositorio con el código desarrollado para el TFG.

## Notas:
- Requeriranse permisos de root, polo que deberá usar sudo en **TODAS** as execucións.
- Antes de comezar execute "entorno.bash" para instalar o entorno necesario.
- Se xa ten instalado hostapd cree unha copia de respaldo dos arquivos de configuración se non os quere perder.
- Para isc-dhcp-server engadiranse os parámetros de confguración ao final do arquivo polo que non se sobreescribirá o orixinal.
- Aínda que pode executar os diferentes códigos por separado, o entorno está deseñado para executar todo a través de "exec.bash"

## Modo de emprego:
### entorno.bash
Arquivo que instala os servizos e scapy. Realiza tamén certas configuracións previas.

### exec.bash
É o arquivo principal, ao executalo irao guiando e solicitando parámetros segundo sexa necesario.

### start_services.bash
Levanta un AP. Se se executa manualmente, o AP terá a configuración da última execución.

### stop_services.bash
Detén o AP e elimina as configuración precisas, como por exemplo as entradas creadas con iptables.

### main.py
Arquivo principal de python encargado de orquestrar os procesos de envío e captura de tramas para atopar coincidencias cos dispositivos cercanos nos SSIDs almaceados.

### listener.py, extract_info.py e packet_definition.py
Son arquivos aos que chama "main.py", non se poden executar por separado.

### hostapd_conf.txt e isc_conf.txt
Arquivos usados para a configuración do AP.

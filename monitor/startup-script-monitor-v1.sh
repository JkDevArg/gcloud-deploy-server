#!/bin/bash

# Archivo de log para depuración
LOGFILE=/var/log/startup_script.log

# Redirigir la salida estándar y de errores al archivo de log
exec > $LOGFILE 2>&1

echo "######################################################################################################"
echo "Script de inicio del sistema DEBIAN"

# Actualiza el sistema y obtenemos paquetes para la instalación de Zabbix
echo "Actualizando el sistema"
sudo wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb
sudo dpkg -i zabbix-release_7.0-2+debian12_all.deb
sudo apt install -y software-properties-common
sudo apt update -y && sudo apt upgrade -y
#!/bin/bash

# Archivo de log para depuración
LOGFILE=/var/log/startup_script.log

# Redirigir la salida estándar y de errores al archivo de log
exec > $LOGFILE 2>&1

echo "######################################################################################################"
echo "Script de inicio del sistema DEBIAN"

# Actualiza el sistema y obtenemos paquetes para instalar PHP 8.3+
echo "Actualizando el sistema"
sudo dpkg -l | grep php | tee packages.txt
sudo apt install -y curl
sudo apt install -y apt-transport-https
sudo curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
sudo apt install -y software-properties-common
sudo apt update -y && sudo apt upgrade -y

# Instalamos los paquetes necesarios
echo "Instalando paquetes"
sudo apt install -y htop screen zip unzip wget composer nano locales-all fail2ban python openjdk-17-jdk

# Detectar el JAVA_HOME y definir SONAR_JAVA_PATH
JAVA_HOME=$(update-java-alternatives -l | awk '{print $3}')
SONAR_JAVA_PATH="$JAVA_HOME/bin/java"
echo "export SONAR_JAVA_PATH=\"$SONAR_JAVA_PATH\"" >> ~/.bashrc
export SONAR_JAVA_PATH="$SONAR_JAVA_PATH"

# Descargamos el proyecto de SonarQube Data Center
wget 'https://storage.googleapis.com/scripts-base-gcp/sonarqube/software/SonarQubeDataCenter.zip'
sudo unzip SonarQubeDataCenter.zip -d /usr/local/bin/sonarqube
sudo chmod 700 /usr/local/bin/sonarqube/bin/linux-x86-x64/sonar.sh

wget 'https://storage.googleapis.com/scripts-base-gcp/sonarqube/servicios/sonarqube.service'
sudo mv sonarqube.service /etc/systemd/system/sonarqube.service

# Recargar los servicios de systemd y habilitar SonarQube
sudo systemctl daemon-reload
sudo systemctl enable sonarqube.service
sudo systemctl start sonarqube.service

# Configura sudoers para permitir a los usuarios del grupo sudo usar sudo sin contraseña
echo "Configurando sudoers"
sudo sed -i '/%sudo/s/^# //' /etc/sudoers
sudo sed -i '/%sudo/s/ALL$/NOPASSWD: ALL/' /etc/sudoers

# Configura la zona horaria y el idioma
echo "Configurando zona horaria y idioma"
sudo localectl set-locale LANG=es_ES.UTF-8
sudo timedatectl set-timezone America/Lima
sudo localedef -i es_ES -f UTF-8 es_ES.UTF-8

# Activa y arranca servicios
echo "Activando y arrancando servicios"
sudo systemctl enable cron
sudo systemctl start cron

echo "Script de instalación todo OK..."
echo "Script de configuración de SonarQube todo Ok"

# Configuración de Fail2Ban
echo "Configurando Fail2Ban"
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Actualizar el PATH y recargar ~/.bashrc
echo "Actualizando el PATH y recargando ~/.bashrc"
echo 'export PATH=$PATH:/usr/sbin' >> ~/.bashrc
export PATH=$PATH:/usr/sbin
source ~/.bashrc
source ~/.profile

echo "######################################################################################################"
echo "Script de configuración terminado, todo OK..."

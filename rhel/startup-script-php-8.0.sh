#!/bin/bash

# Archivo de log para depuración
LOGFILE=/var/log/my-startup-script.log

# Redirigir la salida estándar y de errores al archivo de log
exec > $LOGFILE 2>&1

# Actualiza el sistema
echo "Actualizando el sistema"
sudo yum update -y

# Instalamos los REPOS necesarios para instalar más adelante los paquetes como php o demás
echo "Instalamos los Repos"
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf -y install http://rpms.remirepo.net/enterprise/remi-release-9.rpm
sudo dnf -y install dnf-utils

# Instala paquetes necesarios
echo "Instalando paquetes"
sudo yum install -y git httpd mod_ssl htop screen zip unzip wget certbot composer nano glibc-all-langpacks fail2ban

# Configura sudoers para permitir a los usuarios del grupo wheel usar sudo sin contraseña
echo "Configurando sudoers"
sudo sed -i '/%wheel/s/^# //' /etc/sudoers
sudo sed -i '/%wheel/s/ALL$/NOPASSWD: ALL/' /etc/sudoers

# Añade reglas específicas para el usuario apache
echo "Añadiendo reglas de sudoers para apache"
echo '%apache ALL=(root) NOPASSWD: /sbin/service, /usr/bin/crontab, /bin/systemctl, /bin/nano, /bin/certbot, /usr/bin/composer, /bin/chmod -R 775 /var/www/html/, /usr/bin/tail' | sudo tee -a /etc/sudoers

# Configura la zona horaria y el idioma
echo "Configurando zona horaria y idioma"
sudo localectl set-locale LANG=es_ES.UTF-8
sudo timedatectl set-timezone America/Lima
sudo localedef -i es_ES -f UTF-8 es_ES.UTF-8

# Activa y arranca servicios
echo "Activando y arrancando servicios"
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl enable crond
sudo systemctl start crond

echo "Script de instalación todo OK..."
echo "Script de configuración de Apache y PHP iniciando..."

# Ocultar información del servidor
echo "Ocultando información del servidor"
sudo sed -i 's/^ServerTokens .*/ServerTokens Prod/' /etc/httpd/conf/httpd.conf
sudo sed -i 's/^ServerSignature .*/ServerSignature Off/' /etc/httpd/conf/httpd.conf
# Deshabilitar TRACE
echo 'TraceEnable off' | sudo tee -a /etc/httpd/conf/httpd.conf
# Añadir encabezados de seguridad
echo '<IfModule mod_headers.c>' | sudo tee -a /etc/httpd/conf/httpd.conf
echo '    Header always append X-Frame-Options SAMEORIGIN' | sudo tee -a /etc/httpd/conf/httpd.conf
echo '    Header set X-XSS-Protection "1; mode=block"' | sudo tee -a /etc/httpd/conf/httpd.conf
echo '    Header set X-Content-Type-Options nosniff' | sudo tee -a /etc/httpd/conf/httpd.conf
echo '    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"' | sudo tee -a /etc/httpd/conf/httpd.conf
echo '</IfModule>' | sudo tee -a /etc/httpd/conf/httpd.conf
# Configuración de SSL
echo '<IfModule mod_ssl.c>' | sudo tee -a /etc/httpd/conf.d/ssl.conf
echo '    SSLProtocol all -SSLv3' | sudo tee -a /etc/httpd/conf.d/ssl.conf
echo '    SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH' | sudo tee -a /etc/httpd/conf.d/ssl.conf
echo '</IfModule>' | sudo tee -a /etc/httpd/conf.d/ssl.conf
# Ocultar versión de PHP
echo 'expose_php = off' | sudo tee -a /etc/php.ini
echo 'disable_functions = exec,passthru,shell_exec,system' | sudo tee -a /etc/php.ini
# Añadir etiqueta de seguridad
echo 'ServerTokens Prod' | sudo tee -a /etc/httpd/conf/httpd.conf
echo 'ServerSignature Off' | sudo tee -a /etc/httpd/conf/httpd.conf
# Desactivar índice de directorios
echo "Desactivando índice de directorios"
echo 'Options -Indexes' | sudo tee -a /etc/httpd/conf/httpd.conf

# Eliminar la ruta base donde se muestra que SO está instalado (archivo welcome.conf seguramente)
echo "Eliminando la ruta base del servidor"
sudo rm -f /etc/httpd/conf.d/welcome.conf

# Actualizar el PATH y recargar ~/.bashrc
echo "Actualizando el PATH y recargando ~/.bashrc"
echo 'export PATH=$PATH:/usr/sbin' >> ~/.bashrc
export PATH=$PATH:/usr/sbin
source ~/.bashrc

# Reiniciar Apache para aplicar cambios
echo "Reiniciando Apache"
sudo systemctl restart httpd

# Configuración Node.js usando nvm
echo "Instalando nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

echo "Instalando Node.js versión 20.11.1"
nvm install 20.11.1

# Configuración Fail2Ban
echo "Configurando Fail2Ban"
# Crear archivo de configuración local para Fail2Ban
sudo sh -c 'echo "[sshd]" > /etc/fail2ban/jail.local'
sudo sh -c 'echo "enabled = true" >> /etc/fail2ban/jail.local'
sudo sh -c 'echo "port    = ssh" >> /etc/fail2ban/jail.local'
sudo sh -c 'echo "logpath = /var/log/auth.log" >> /etc/fail2ban/jail.local'
sudo sh -c 'echo "backend = systemd" >> /etc/fail2ban/jail.local'

# Configuración de Fail2Ban
echo "Configurando Fail2Ban"
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "######################################################################################################"
echo "Script de configuración terminado, todo OK..."

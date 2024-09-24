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
sudo apt install -y git apache2 libapache2-mod-php openssl grpc
sudo apt install -y htop screen zip unzip wget certbot composer nano locales-all fail2ban python3-certbot-apache
sudo apt install -y php8.3 php8.3-fpm php8.3-cli php8.3-{bz2,curl,mbstring,intl} php8.3-xml php8.3-mysqli php8.3-gd php8.3-zip php8.3-dev

# En Apache: activamos PHP 8.3 FPM
sudo a2enconf php8.3-fpm

# Configura sudoers para permitir a los usuarios del grupo sudo usar sudo sin contraseña
echo "Configurando sudoers"
sudo sed -i '/%sudo/s/^# //' /etc/sudoers
sudo sed -i '/%sudo/s/ALL$/NOPASSWD: ALL/' /etc/sudoers

# Añade reglas específicas para el usuario www-data (Apache en Debian)
echo "Añadiendo reglas de sudoers para www-data"
echo '%www-data ALL=(root) NOPASSWD: /usr/sbin/service, /usr/bin/crontab, /bin/systemctl, /bin/nano, /usr/bin/certbot, /usr/bin/composer, /bin/chmod -R 775 /var/www/html/, /usr/bin/tail' | sudo tee -a /etc/sudoers

# Configura la zona horaria y el idioma
echo "Configurando zona horaria y idioma"
sudo localectl set-locale LANG=es_ES.UTF-8
sudo timedatectl set-timezone America/Lima
sudo localedef -i es_ES -f UTF-8 es_ES.UTF-8

# Activa y arranca servicios
echo "Activando y arrancando servicios"
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable cron
sudo systemctl start cron

echo "Script de instalación todo OK..."
echo "Script de configuración de Apache y PHP iniciando..."

# Ocultar información del servidor
echo "Ocultando información del servidor"
sudo sed -i 's/^ServerTokens .*/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
sudo sed -i 's/^ServerSignature .*/ServerSignature Off/' /etc/apache2/conf-available/security.conf

# Deshabilitar TRACE
echo 'TraceEnable off' | sudo tee -a /etc/apache2/conf-available/security.conf

# Añadir encabezados de seguridad
echo '<IfModule mod_headers.c>' | sudo tee -a /etc/apache2/conf-available/security.conf
echo '    Header always append X-Frame-Options SAMEORIGIN' | sudo tee -a /etc/apache2/conf-available/security.conf
echo '    Header set X-XSS-Protection "1; mode=block"' | sudo tee -a /etc/apache2/conf-available/security.conf
echo '    Header set X-Content-Type-Options nosniff' | sudo tee -a /etc/apache2/conf-available/security.conf
echo '    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"' | sudo tee -a /etc/apache2/conf-available/security.conf
echo '</IfModule>' | sudo tee -a /etc/apache2/conf-available/security.conf

# Configuración de SSL
echo '<IfModule mod_ssl.c>' | sudo tee -a /etc/apache2/mods-available/ssl.conf
echo '    SSLProtocol all -SSLv3' | sudo tee -a /etc/apache2/mods-available/ssl.conf
echo '    SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH' | sudo tee -a /etc/apache2/mods-available/ssl.conf
echo '</IfModule>' | sudo tee -a /etc/apache2/mods-available/ssl.conf

# Ocultar versión de PHP
echo 'expose_php = off' | sudo tee -a /etc/php/8.3/apache2/php.ini
echo 'disable_functions = exec,passthru,shell_exec,system' | sudo tee -a /etc/php/8.3/apache2/php.ini

# Añadir etiqueta de seguridad
echo 'ServerTokens Prod' | sudo tee -a /etc/apache2/conf-available/security.conf
echo 'ServerSignature Off' | sudo tee -a /etc/apache2/conf-available/security.conf

# Desactivar índice de directorios
echo "Desactivando índice de directorios"
echo 'Options -Indexes' | sudo tee -a /etc/apache2/apache2.conf

# Eliminar la ruta base donde se muestra que SO está instalado
echo "Eliminando la ruta base del servidor"
sudo rm -rf /var/www/html/index.html
sudo rm -f /etc/apache2/conf-enabled/serve-cgi-bin.conf

# Agregar configuración para directorio raíz
echo "Configurando permisos de acceso al directorio raíz"
sudo sh -c 'echo "<Directory /var/www/html>" >> /etc/apache2/apache2.conf'
sudo sh -c 'echo "    Options -Indexes" >> /etc/apache2/apache2.conf'
sudo sh -c 'echo "    Require all granted" >> /etc/apache2/apache2.conf'
sudo sh -c 'echo "</Directory>" >> /etc/apache2/apache2.conf'

# Reiniciar Apache para aplicar cambios
echo "Reiniciando Apache"
sudo systemctl restart apache2

# Agregamos los permisos para el grupo www-data en archivo visudo
echo "Agregando permisos para el grupo www-data"
echo '%www-data ALL=(root) NOPASSWD: /usr/sbin/service, /usr/bin/crontab, /bin/systemctl, /bin/nano, /usr/bin/certbot, /usr/bin/composer, /bin/chmod -R 775 /var/www/html/, /usr/bin/tail, /usr/bin/cp, /usr/sbin/a2ensite, /usr/sbin/a2dissite, /usr/sbin/a2enmod' | sudo tee -a /etc/sudoers

# Copiamos el archivo de cron en la carepta cron/renew_ssl_v2.sh
sudo cp ./cron/renew_ssl_v2.sh /etc/cron.d/renew_ssl_v2.sh

# Agregar el siguiente comando en el cron 00 01 * * * /bin/bash /home/scripts/renew_ssl_v2.sh
echo "Agregando cron para renovar certificados"
echo "00 01 * * * /bin/bash /home/scripts/renew_ssl_v2.sh" | sudo tee -a /etc/crontab


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

# Actualizar el PATH y recargar ~/.bashrc
echo "Actualizando el PATH y recargando ~/.bashrc"
echo 'export PATH=$PATH:/usr/sbin' >> ~/.bashrc
export PATH=$PATH:/usr/sbin
source ~/.bashrc
source ~/.profile

echo "######################################################################################################"
echo "Script de configuración terminado, todo OK..."

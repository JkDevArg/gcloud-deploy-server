Documentación Oficial

https://cloud.google.com/deployment-manager/docs?hl=es-419

https://cloud.google.com/sdk/docs/install-sdk?hl=es-419

https://cloud.google.com/sdk/docs/how-to?hl=es-419

https://cloud.google.com/deployment-manager/docs/deployments/viewing-manifest?hl=es-419

https://cloud.google.com/deployment-manager/docs/reference/cloud-foundation-toolkit

Instalación

Instalar la versión más reciente de gcloud CLI

(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe") & $env:Temp\GoogleCloudSDKInstaller.exe


Al finalizar saldrá lo siguiente:

Welcome to the Google Cloud CLI! Run "gcloud -h" to get the list of available commands.
Welcome! This command will take you through the configuration of gcloud.

Your current configuration has been set to: [default]

You can skip diagnostics next time by using the following flag:
  gcloud init --skip-diagnostics

Network diagnostic detects and fixes local network connection issues.
Checking network connection...done.
Reachability Check passed.
Network diagnostic passed (1/1 checks passed).


Iniciar sesión desde el navegador

You must log in to continue. Would you like to log in (Y/n)?

Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=

You are logged in as: [hola@focusit.pe].



Luego seleccionamos la siguiente opción: (En este caso seria focus-innovacion

Pick cloud project to use:
 [1] crested-epoch-422317-i4
 [2] focus-innovacion
 [3] gen-lang-client-0978998262
 [4] indriveclone
 [5] proyecto-backups-382615
 [6] Enter a project ID
 [7] Create a new project
Please enter numeric choice or text value (must exactly match list item):  2

Your current project has been set to: [focus-innovacion].



Seguir los pasos para terminar con la instalación de GCP CLI

Do you want to configure a default Compute Region and Zone? (Y/n)?  n

Created a default .boto configuration file at [C:\Users\Usuario\.boto]. See this file and
[https://cloud.google.com/storage/docs/gsutil/commands/config] for more
information about configuring Google Cloud Storage.
Your Google Cloud SDK is configured and ready to use!

* Commands that require authentication will use jcenturion@focusit.pe by default
* Commands will reference project `focus-innovacion` by default
Run `gcloud help config` to learn how to change individual settings

This gcloud configuration is called [default]. You can create additional configurations if you work with multiple accounts and/or projects.
Run `gcloud topic configurations` to learn more.

Some things to try next:

* Run `gcloud --help` to see the Cloud Platform services you can interact with. And run `gcloud help COMMAND` to get help on any gcloud command.
* Run `gcloud topic --help` to learn about advanced features of the SDK like arg files and output formatting
* Run `gcloud cheat-sheet` to see a roster of go-to `gcloud` commands.



Habilitar Permisos en GCP 

Luego de instalar debemos tener habilitados algunos permisos para que GCP pueda usar esos permisos para crear una Instancia o lo necesario en el transcurso de la documentación.



Debemos ir al siguiente enlace:

https://cloud.google.com/deployment-manager/docs/step-by-step-guide/installation-and-setup?hl=es-419 

Debemos habilitar las dos siguientes API para no tener problemas a futuro.



Comandos

Comandos necesarios que hay que tener en cuenta:

Enumera las cuentas cuyas credenciales están almacenadas en el sistema local:

gcloud auth list

Gcloud CLI muestra una lista de cuentas con credenciales:

Credentialed Accounts
ACTIVE             ACCOUNT
*                  example-user-1@gmail.com
                   example-user-2@gmail.com

Enumera las propiedades en tu configuración activa de gcloud CLI:

gcloud config list

Gcloud CLI muestra la lista de propiedades:

[core]
account = example-user-1@gmail.com
disable_usage_reporting = False
project = example-project

Ver información sobre la instalación de gcloud CLI y la actividad actual:

gcloud info

gcloud CLI muestra un resumen de la información sobre tus instalación. Esto incluye información sobre tu sistema, los componentes instalados, la cuenta de usuario activa y el proyecto actual las propiedades en la configuración activa.

Consulta la información sobre los comandos de gcloud y otros temas:

gcloud help

Por ejemplo, para ver la ayuda de gcloud compute instances create:

gcloud help compute instances create

Gcloud CLI muestra un tema de ayuda que contiene un descripción del comando, una lista de las marcas y los argumentos del comando, y ejemplos de cómo usar el comando.



Comandos para deployar un proyecto.

gcloud deployment-manager deployments create my-deployment --config deployment.yaml

Comando para borrar el deploy creado

gcloud deployment-manager deployments delete deployment-with-2-vms

Comando para listar los proyectos creados

gcloud deployment-manager deployments list

Comando para listar imágenes disponibles en GCP

gcloud compute images list --project=rhel-cloud

Creación IP GCP

Nos servirá crear una IP fija para luego usarla en la maquina virtual que crearemos.

Reservar una IP estática:

gcloud compute addresses create my-static-ip-1 --region us-central1
gcloud compute addresses create my-static-ip-2 --region us-central1

Una vez creada utilizaremos el siguiente comando:

gcloud compute addresses list

Creación Bucket GCP (Opcional)

Esto se alojara los scripts en Bash para ejecutar la plantilla de Deploy, esto solo se hará si no existe un bucket o el bucket.

gsutil mb gs://scripts-base-gcp



Subir los scripts al servidor 

gsutil cp startup-script-php-8.3.8.sh gs://scripts-base-gcp/
gsutil cp startup-script-php-8.0.30.sh gs://scripts-base-gcp/

Plantilla de Deployment Manage

imports:
  - path: instance-template.jinja

resources:
  - name: vm-instance-php-8-3-8
    type: instance-template.jinja
    properties:
      zone: us-central1-a
      machineType: e2-small
      diskImage: projects/rhel-cloud/global/images/rhel-9-v20240709
      externalIp: 35.226.205.94
      metadata:
        startup-script: |
          #!/bin/bash
          echo "Hello, World!" > /tmp/hello.txt
          curl -o /tmp/startup-script.sh https://storage.googleapis.com/scripts-base-gcp/startup-script-php-8.3.sh
          chmod +x /tmp/startup-script.sh
          /tmp/startup-script.sh

  - name: vm-instance-php-8-0-30
    type: instance-template.jinja
    properties:
      zone: us-central1-a
      machineType: e2-small
      diskImage: projects/rhel-cloud/global/images/rhel-9-v20240709
      externalIp: 146.148.36.172
      metadata:
        startup-script: |
          #!/bin/bash
          echo "Hello, World!" > /tmp/hello.txt
          curl -o /tmp/startup-script.sh https://storage.googleapis.com/scripts-base-gcp/startup-script-php-8.0.sh
          chmod +x /tmp/startup-script.sh
          /tmp/startup-script.sh


{% set REGION = properties["zone"].split("-")[0] + "-" + properties["zone"].split("-")[1] %}

resources:
  - name: {{ env["name"] }}
    type: compute.v1.instance
    properties:
      zone: {{ properties["zone"] }}
      machineType: zones/{{ properties["zone"] }}/machineTypes/{{ properties["machineType"] }}
      metadata:
        items:
          - key: startup-script
            value: {{ properties["metadata"]["startup-script"] | tojson }}
      networkInterfaces:
        - network: global/networks/default
          accessConfigs:
            - name: External NAT
              type: ONE_TO_ONE_NAT
              natIP: {{ properties["externalIp"] }}
      disks:
        - deviceName: boot
          type: PERSISTENT
          boot: true
          autoDelete: true
          initializeParams:
            sourceImage: {{ properties["diskImage"] }}
      tags:
        items:
          - http-server
          - https-server


#!/bin/bash

# Archivo de log para depuración
LOGFILE=/var/log/my-startup-script.log

# Redirigir la salida estándar y de errores al archivo de log
exec > $LOGFILE 2>&1

# Actualiza el sistema
echo "Actualizando el sistema"
sudo yum update -y

# Instalamos los REPOS  necesarios para instalar mas adelante los paquetes como php o demás
echo "Instalamos los Repos"
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf -y install http://rpms.remirepo.net/enterprise/remi-release-9.rpm
sudo dnf -y install dnf-utils

# Instala paquetes necesarios


echo "Instalando paquetes"
sudo yum install -y git httpd mod_ssl htop screen php-8.0.30 zip unzip wget certbot composer nano glibc-all-langpacks fail2ban

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

# Reiniciar Apache para aplicar cambios
echo "Reiniciando Apache"
sudo systemctl restart httpd

echo "######################################################################################################"
echo "######################################################################################################"
echo "######################################################################################################"
echo "Script de configuración terminado, todo OK..."

#!/bin/bash

# Archivo de log para depuración
LOGFILE=/var/log/my-startup-script.log

# Redirigir la salida estándar y de errores al archivo de log
exec > $LOGFILE 2>&1

# Actualiza el sistema
echo "Actualizando el sistema"
sudo yum update -y

# Instalamos los REPOS  necesarios para instalar mas adelante los paquetes como php o demás
echo "Instalamos los Repos"
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf -y install http://rpms.remirepo.net/enterprise/remi-release-9.rpm
sudo dnf -y install dnf-utils

# Instala paquetes necesarios
echo "Instalando paquetes"
sudo dnf module install -y php:remi-8.3
sudo yum install -y git httpd mod_ssl
sudo yum install -y htop screen zip unzip wget certbot composer nano glibc-all-langpacks fail2ban

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

# Reiniciar Apache para aplicar cambios
echo "Reiniciando Apache"
sudo systemctl restart httpd

echo "######################################################################################################"
echo "######################################################################################################"
echo "######################################################################################################"
echo "Script de configuración terminado, todo OK..."




Deployar el proyecto

gcloud deployment-manager deployments create my-deployment --config deployment.yaml



Si por algún motivo arroja error borrar el proyecto 

gcloud deployment-manager deployments delete my-deployment



Para validar si se ha creado correctamente ir al enlace del proyecto

https://console.cloud.google.com/compute/instances?hl=es&project=PROYECTO-DONDE-SE-CREO


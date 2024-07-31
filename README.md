# Documentación Oficial

[Google Deployment Manager Docs](https://cloud.google.com/deployment-manager/docs?hl=es-419)

[Google Cloud SDK Docs](https://cloud.google.com/sdk/docs/install-sdk?hl=es-419)

[Google Cloud SDK Docs](https://cloud.google.com/sdk/docs/how-to?hl=es-419)

[Google Deployment Manager Docs](https://cloud.google.com/deployment-manager/docs/deployments/viewing-manifest?hl=es-419)

[Cloud Foundation Toolkit Reference](https://cloud.google.com/deployment-manager/docs/reference/cloud-foundation-toolkit)


Instalación

Instalar la versión más reciente de gcloud CLI

```bash
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe") & $env:Temp\GoogleCloudSDKInstaller.exe
```

```bash
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
```

Iniciar sesión desde el navegador

```bash
You must log in to continue. Would you like to log in (Y/n)?

Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=

You are logged in as: [hola@focusit.pe].
```

Luego seleccionamos la siguiente opción: (En este caso seria focus-innovacion

```bash
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
```

Seguir los pasos para terminar con la instalación de GCP CLI

```bash
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
```

Habilitar Permisos en GCP

Luego de instalar debemos tener habilitados algunos permisos para que GCP pueda usar esos permisos para crear una Instancia o lo necesario en el transcurso de la documentación.

Debemos ir al siguiente enlace:

[Google Cloud Deployment Manager Step-by-Step Guide](https://cloud.google.com/deployment-manager/docs/step-by-step-guide/installation-and-setup?hl=es-419)

Debemos habilitar las dos siguientes API para no tener problemas a futuro.

Debemos habilitar las dos siguientes API para no tener problemas a futuro.

Comandos

Comandos necesarios que hay que tener en cuenta:

Enumera las cuentas cuyas credenciales están almacenadas en el sistema local:

```bash
gcloud auth list
```

Gcloud CLI muestra una lista de cuentas con credenciales:

```bash
Credentialed Accounts
ACTIVE             ACCOUNT
*                  example-user-1@gmail.com
                   example-user-2@gmail.com
```

Enumera las propiedades en tu configuración activa de gcloud CLI:

```bash
gcloud config list
```

Gcloud CLI muestra la lista de propiedades:

```bash
[core]
account = example-user-1@gmail.com
disable_usage_reporting = False
project = example-project
```

Ver información sobre la instalación de gcloud CLI y la actividad actual:

```bash
gcloud info
```

gcloud CLI muestra un resumen de la información sobre tus instalación. Esto incluye información sobre tu sistema, los componentes instalados, la cuenta de usuario activa y el proyecto actual las propiedades en la configuración activa.

Consulta la información sobre los comandos de gcloud y otros temas:

```bash
gcloud help
```

Por ejemplo, para ver la ayuda de gcloud compute instances create:

```bash
gcloud help compute instances create
```

Gcloud CLI muestra un tema de ayuda que contiene un descripción del comando, una lista de las marcas y los argumentos del comando, y ejemplos de cómo usar el comando.


Comandos para deployar un proyecto.

```bash
gcloud deployment-manager deployments create my-deployment --config deployment.yaml
```

Comando para borrar el deploy creado

```bash
gcloud deployment-manager deployments delete deployment-with-2-vms
```

Comando para listar los proyectos creados

```bash
gcloud deployment-manager deployments list
```

Comando para listar imágenes disponibles en GCP

```bash
gcloud compute images list --project=rhel-cloud
```

Creación IP GCP

Nos servirá crear una IP fija para luego usarla en la maquina virtual que crearemos.

Reservar una IP estática:

```bash
gcloud compute addresses create my-static-ip-1 --region us-central1
gcloud compute addresses create my-static-ip-2 --region us-central1
```

Una vez creada utilizaremos el siguiente comando:

```bash
gcloud compute addresses list
```

Creación Bucket GCP (Opcional)

Esto se alojara los scripts en Bash para ejecutar la plantilla de Deploy, esto solo se hará si no existe un bucket o el bucket.

```bash
gsutil mb gs://scripts-base-gcp
```

Subir los scripts al servidor

```bash
gsutil cp startup-script-php-8.3.8.sh gs://scripts-base-gcp/
gsutil cp startup-script-php-8.0.30.sh gs://scripts-base-gcp/
```

Plantilla de Deployment Manage

```bash
imports:
  - path: instance-template.jinja

resources:
  - name: vm-instance-php-8-3-8
    type: instance-template.jinja
    properties:
      zone: us-central1-a
      machineType: e2-small
      diskImage: projects/rhel-cloud/global/images/rhel-9-v20240709
      externalIp: YOUR_IP_EXTERNA
      metadata:
        startup-script: |
          #!/bin/bash
          echo "Hello, World!" > /tmp/hello.txt
          curl -o /tmp/startup-script.sh https://storage.googleapis.com/YOUR_FOLDER/startup-script-php-8.3.sh
          chmod +x /tmp/startup-script.sh
          /tmp/startup-script.sh

  - name: vm-instance-php-8-0-30
    type: instance-template.jinja
    properties:
      zone: us-central1-a
      machineType: e2-small
      diskImage: projects/rhel-cloud/global/images/rhel-9-v20240709
      externalIp: YOUR_IP_EXTERNA
      metadata:
        startup-script: |
          #!/bin/bash
          echo "Hello, World!" > /tmp/hello.txt
          curl -o /tmp/startup-script.sh https://storage.googleapis.com/YOUR_FOLDER/startup-script-php-8.0.sh
          chmod +x /tmp/startup-script.sh
          /tmp/startup-script.sh
```

Deployar el proyecto

```bash
gcloud deployment-manager deployments create my-deployment --config deployment.yaml
```

Si por algún motivo arroja error borrar el proyecto

```bash
gcloud deployment-manager deployments delete my-deployment
```

Para validar si se ha creado correctamente ir al enlace del proyecto

```bash
https://console.cloud.google.com/compute/instances?hl=es&project=PROYECTO-DONDE-SE-CREO
```
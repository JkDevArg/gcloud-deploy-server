#!/bin/bash

# Ruta del archivo de log
LOG_FILE="/var/log/certbot_renewal.log"
# Consultamos los cert activos
active_cert=$(sudo certbot certificates)
# Obtener la fecha de hoy
date_now=$(date +%s)
# Arreglo para almacenar certificados que caducan en 7 días o menos
renew_cert=()
# Recorremos los certificados y agregamos los que caducan en 7 días o menos al arreglo
while IFS= read -r line; do
  if [[ $line == *"Domains: "* ]]; then
    domain_name=$(echo "$line" | awk '{print $2}')  # Obtener el segundo campo (el nombre del dominio)
  fi

  if [[ $line == *"Expiry Date: "* ]]; then
      # Extraemos los días restantes
      days=$(echo "$line" | grep -oP 'VALID: \K\d+')
      if [ -z "$days" ]; then
          days=0
      fi

      # Establecer la bandera cuando se encuentre la línea relevante del certificado
      if [ $days -le 7 ]; then
          renew_cert+=("$domain_name")
      fi


  fi
done <<< "$active_cert"

echo ${#renew_cert[@]}
# Verificar si hay certificados para renovar antes de continuar
if [ ${#renew_cert[@]} -gt 0 ]; then

  # Detenemos el apache
  sudo service httpd stop

  # Recorrer el arreglo y renovar los certificados y guardar en el log los que se hayan actualizado
  for cert_name in "${renew_cert[@]}"; do
    sudo certbot renew --cert-name "$cert_name" --quiet > "$LOG_FILE" 2>&1
  done

  # Levantamos el apache
  sudo service httpd start

fi
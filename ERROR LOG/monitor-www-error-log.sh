#!/bin/bash

# URL del webhook
WEBHOOK_URL="https://chat.googleapis.com/v1/spaces/AAAAhCFw1tI/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=ncIuUZ8l7rpXuTXoqfZkSHZequqPP73xg2Fu_bLy7EQ"

# WEB HOOK DE PRUEBA
# WEBHOOK_URL="https://chat.googleapis.com/v1/spaces/AAAAVgORTxs/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=kdYeUsMfycsMj2tkcNzcrFbmWmZCxycTiJws7ApLCd4"

# Archivo de log para monitorizar
LOG_FILE="/var/log/php-fpm/www-error.log"

# Archivo temporal para almacenar el último error
TMP_LOG="/tmp/monitor-log-debug.log"

# Leer el archivo de log y obtener el último error
tail -F "$LOG_FILE" | while read -r line; do
    # Verificar si la línea contiene un error
    if [[ "$line" == *"Fatal"* || "$line" == *"Warning"* ]]; then
        # Reemplazar el contenido del archivo temporal con el último error
        echo "$line" > "$TMP_LOG"
        
        # Enviar el último error al webhook
        curl -X POST -H 'Content-Type: application/json' \
             -d "{\"text\": \"$(echo "$line" | sed 's/"/\\"/g')\"}" \
             "$WEBHOOK_URL"
    fi
done

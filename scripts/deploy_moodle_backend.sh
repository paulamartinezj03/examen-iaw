#!/bin/bash

# Configuramos para mostrar los comandos y finalizar si hay error
set -ex

#Importamos las variables de entorno
source .env

# Creamos la base de datos y el usuario para WordPress
mysql -e "DROP DATABASE IF EXISTS $MOODLE_DB_NAME"
mysql -e "CREATE DATABASE $MOODLE_DB_NAME"
mysql -e "DROP USER IF EXISTS $MOODLE_DB_USER@'$FRONTEND_PRIVATE_IP'"
mysql -e "CREATE USER $MOODLE_DB_USER@'$FRONTEND_PRIVATE_IP' IDENTIFIED BY '$MOODLE_DB_PASS'"
mysql -e "GRANT ALL PRIVILEGES ON $MOODLE_DB_NAME.* TO $MOODLE_DB_USER@'$FRONTEND_PRIVATE_IP'"
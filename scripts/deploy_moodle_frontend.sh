#!/bin/bash

# Configuramos para mostrar los comandos y finalizar si hay error
set -ex

#Importamos las variables de entorno
source .env

# Habilitamos el modulo rewrite
a2enmod rewrite

#Eliminamos los archivos de instalaciones previas de Moodle de /var/www/html/moodle
rm -rf /tmp/v4.3.1.zip
rm -rf /var/www/html/*

# Descargamos el codigo fuente de Moodle
wget https://github.com/moodle/moodle/archive/refs/tags/v4.3.1.zip -P /tmp

#Descomprimimos el codigo fuente de Moodle en la carpeta /var/www/html/moodle
apt install unzip -y
unzip /tmp/v4.3.1.zip -d /tmp

# Movemos el contenido de la carpeta descomprimida /var/www/html
mv /tmp/moodle-4.3.1/* /var/www/html

# Cambiamos el propietario de la carpeta para que sea propiedad del servidor y dar acceso al dueño de lectura, escritura y ejecución.
chown -R www-data:www-data /var/www/html
chmod -R 0755 /var/www/html

# Creamos un directorio fuera de la raíz web para mayor seguridad en /var/moodledata
mkdir -p /var/moodledata

# Damos permisos a la carpeta /var/www/html/moodledata
chown -R www-data:www-data /var/moodledata
chmod -R 777 /var/moodledata

#Cambiamos las variables del archivo de php.ini tanto en la carpeta /apache2 como en /cli
sed -i "s/;max_input_vars = 1000/max_input_vars = 5000/" /etc/php/8.3/apache2/php.ini
sed -i "s/;max_input_vars = 1000/max_input_vars = 5000/" /etc/php/8.3/cli/php.ini

# Hacemos la configuracion automatica de la instalacion de Moodle
sudo -u www-data php /var/www/html/admin/cli/install.php \
    --lang=$MOODLE_LANG \
    --wwwroot=$MOODLE_WWWROOT \
    --dataroot=$MOODLE_DATAROOT \
    --dbtype=$MOODLE_DB_TYPE \
    --dbhost=$BACKEND_PRIVATE_IP \
    --dbname=$MOODLE_DB_NAME \
    --dbuser=$MOODLE_DB_USER \
    --dbpass=$MOODLE_DB_PASS \
    --fullname="$MOODLE_FULLNAME" \
    --shortname="$MOODLE_SHORTNAME" \
    --summary="$MOODLE_SUMMARY" \
    --adminuser=$MOODLE_ADMIN_USER \
    --adminpass=$MOODLE_ADMIN_PASS \
    --adminemail=$MOODLE_ADMIN_EMAIL \
    --non-interactive \
    --agree-license

# Configurar unos valores 
sed -i "/\$CFG->admin/a \$CFG->reverseproxy=1;\n\$CFG->sslproxy=1;" /var/www/html/config.php

# Reiniciamos apache para que todos los cambios que hemos hecho durante la configuracion se guarden
systemctl reload apache2
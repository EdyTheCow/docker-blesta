#!/bin/sh

DIR="/var/www/html"

if [ "$(ls -A $DIR)" ]; then
     echo "$DIR is not empty"
else
    cp -R /var/www/blesta/. /var/www/html
fi


PUID=${PUID:-1070}
PGID=${PGID:-1070}
groupmod -o -g "$PGID" nobody
usermod -o -u "$PUID" nobody


exec "$@"

#!/bin/bash
if [[ "${PARAMS}" == "nginx" ]]; then
        chown -R www.www /var/web
        find /var/web/www -type d -exec chmod 750 {} \;
        find /var/web/www -not -type d -exec chmod 640 {} \;
        find /var/web/www -name "storage" -type d -exec chmod -R 777 {} \;
        /usr/local/openresty/nginx/sbin/nginx -g "daemon off;"

fi

if [[ "${PARAMS}" == "php" ]]; then
        chown -R www.www /var/web
        find /var/web/www -type d -exec chmod 750 {} \;
        find /var/web/www -not -type d -exec chmod 640 {} \;
        find /var/web/www -name "storage" -type d -exec chmod -R 777 {} \;
        php-fpm 
fi
exec "$@"

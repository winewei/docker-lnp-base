#!/bin/bash
if [[ "${PARAMS}" == "nginx" ]]; then
        chown -R www.www /srv
        /usr/local/openresty/nginx/sbin/nginx -g "daemon off;"
fi

if [[ "${PARAMS}" == "php" ]]; then
        php-fpm
        if [[ "${ENABLE_LARAVEL_CONFIG_CACHE}" == "true" ]]; then
            php artisan config:cache
            php artisan route:cache
        fi
		find /srv -name "storage" -type d -exec chmod -R 777 {} \;
		find /srv -name "bootstrap" -type d -exec chmod -R 777 {} \;
fi
exec "$@"

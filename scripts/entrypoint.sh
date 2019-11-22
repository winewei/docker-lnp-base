#!/usr/bin/env bash
set -e

# Take nginx/php env
replaces=`compgen -v | grep -E 'NGINX_|PHP_' | awk '{print "\${"$0"}"}' | tr '\n' ','`
replaces="'$replaces'"

chmod +x /scripts/init.d/*

# Start nginx
if [[ "${PARAMS}" == "nginx" ]]; then
        # Init config
        echo "/scripts/init.d/init-${PARAMS}.sh"
        . /scripts/init.d/init-${PARAMS}.sh

        /usr/local/openresty/nginx/sbin/nginx -g "daemon off;"

# Start php
elif [[ "${PARAMS}" == "php" ]]; then
        # Init config
        echo "/scripts/init.d/init-${PARAMS}.sh"
        . /scripts/init.d/init-${PARAMS}.sh

        php-fpm
else
        echo "Please input env: nginx,php or exec what's u need"
fi

exec "$@"

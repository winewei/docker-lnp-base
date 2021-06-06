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

        exec /usr/local/openresty/nginx/sbin/nginx -g "daemon off;"

# Start php
elif [[ "${PARAMS}" == "php" ]]; then
        # Init config
        echo "/scripts/init.d/init-${PARAMS}.sh"
        . /scripts/init.d/init-${PARAMS}.sh

        exec php-fpm
# Start php,nginx
elif [[ "${PARAMS}" == "all" ]]; then
        # Init config
        echo "/scripts/init.d/init-php.sh"
        . /scripts/init.d/init-php.sh

        echo "/scripts/init.d/init-nginx.sh"
        . /scripts/init.d/init-nginx.sh

        /usr/local/openresty/nginx/sbin/nginx
        php-fpm
else
        echo "Please input env: nginx,php,all or exec input everything"
fi

exec "$@"

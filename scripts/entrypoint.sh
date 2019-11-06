#!/usr/bin/env bash
set -e

replaces=`compgen -v | grep -E 'NGINX_|PHP_' |awk '{print "\${"$0"}"}' | tr '\n' ','`
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

# Init npm/github token
else
        echo "/scripts/token-init.sh"
        . /scripts/token-init.sh
fi

exec "$@"

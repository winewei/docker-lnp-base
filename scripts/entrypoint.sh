#!/usr/bin/env bash
set -e

# Init npm/github token
. /scripts/token-init.sh

# Init config
init_scripts="/scripts/init.d/*"
for script in $init_scripts; do
    if [ -f $script -a -x $script ]; then
        echo "start init script: ${script}"
        . $script
    fi
done

# Start nginx
if [[ "${PARAMS}" == "nginx" ]]; then
        /usr/local/openresty/nginx/sbin/nginx -g "daemon off;"
fi

# Start php
if [[ "${PARAMS}" == "php" ]]; then
        php-fpm
fi

exec "$@"

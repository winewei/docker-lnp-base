#!/usr/bin/env bash
set -e



# Start nginx
if [[ "${PARAMS}" == "nginx" ]]; then
        /usr/local/openresty/nginx/sbin/nginx -g "daemon off;"
# Start php
elif [[ "${PARAMS}" == "php" ]]; then
        # Init config
        init_scripts="/scripts/init.d/*"
        for script in $init_scripts; do
            if [ -f $script -a -x $script ]; then
                echo "start init script: ${script}"
                . $script
            fi
        done

        php-fpm
else
        # Init npm/github token
        . /scripts/token-init.sh
fi

exec "$@"

#!/usr/bin/env bash
set -e

if [[ "${PARAMS}" == "nginx" ]]; then
        /usr/local/openresty/nginx/sbin/nginx -g "daemon off;"
fi

if [[ "${PARAMS}" == "php" ]]; then
        init_scripts="/scripts/init.d/*"
        for script in $init_scripts; do
            if [ -f $script -a -x $script ]; then
                echo "start init script: ${script}"
                . $script
            fi
        done

        php-fpm
fi
exec "$@"

#!/usr/bin/env bash
set -e

if [[ "${PARAMS}" == "php" ]]; then
   envsubst < "/conf-temp/php.ini-production.temp" > "/usr/local/etc/php/php.ini"   
   envsubst < "/conf-temp/php-fpm.conf.temp" > "/usr/local/etc/php-fpm.conf"
fi

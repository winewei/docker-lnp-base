#!/usr/bin/env bash
set -e

if [[ "${PARAMS}" == "nginx" ]]; then
   envsubst < "/conf-temp/nginx-default.conf.temp" > "/usr/local/openresty/nginx/conf/vhosts/default.conf"
fi

#!/usr/bin/env bash
set -e


if [[ "${PARAMS}" == "nginx" ]]; then
   envsubst $replaces < "/conf-temp/nginx-default.conf.temp" > "/usr/local/openresty/nginx/conf/vhosts/default.conf"
   envsubst $replaces < "/conf-temp/nginx.conf.temp" > "/usr/local/openresty/nginx/conf/nginx.conf"
fi

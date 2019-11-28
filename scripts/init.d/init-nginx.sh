#!/usr/bin/env bash
set -e


if [[ "${PARAMS}" == "nginx" ]]; then
  # if exist config file, will skip generate
  # to fix:
  #    when container been mount new config files via readonly volumes will trigger ERROR
  #
  if [ ! -f /usr/local/openresty/nginx/conf/vhosts/default.conf ]; then
    mkdir -p /usr/local/openresty/nginx/conf/vhosts/;
    envsubst $replaces < "/conf-temp/nginx-default.conf.temp" > "/usr/local/openresty/nginx/conf/vhosts/default.conf";
  fi

  if [ ! -f /usr/local/openresty/nginx/conf/nginx.conf ]; then
    mkdir -p /usr/local/openresty/nginx/conf/;
    envsubst $replaces < "/conf-temp/nginx.conf.temp" > "/usr/local/openresty/nginx/conf/nginx.conf";
  fi
fi

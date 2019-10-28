#!/usr/bin/env bash
set -e

replaces=`compgen -v | grep 'PHP_'|awk '{print "\${"$0"}"}' | tr '\n' ','`
replaces="'$replaces'"

if [[ "${PARAMS}" == "php" ]]; then
   envsubst $replaces < "/conf-temp/php.ini-production.temp" > "/usr/local/etc/php/php.ini"   
fi

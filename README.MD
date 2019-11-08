# PHP base image
`Be based on php official image`

```
- Include php-fpm 7.*
- Include phpunit
- Include composer
- Include pecl
- Include openresty
```
## PHP 7.0/7.1/7.2/7.3 modules
`PHP 7.0/7.1 dose not include sodium lib`
```
[PHP Modules]
bcmath
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gettext
hash
iconv
igbinary
json
libxml
mbstring
mongodb
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
readline
redis
Reflection
session
shmop
SimpleXML
soap
sockets
sodium
SPL
sqlite3
standard
swoole
sysvsem
tokenizer
xml
xmlreader
xmlrpc
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

## ENV
Default env in `Dockerfile`
```
PARAMS="" # php/nginx
GITHUB_USER=""
COMPOSER_AUTH=""

# php.ini 
PHP_UPLOAD_MAX_FILESIZE="8M" 
PHP_POST_MAX_SIZE="8M" 
PHP_MAX_EXECUTION_TIME="600" 
PHP_MAX_INPUT_TIME="600" 
PHP_MEMORY_LIMIT="128M" 

# php-fpm 
PHP_REQUEST_TERMINATE_TIMEOUT="65" 
PHP_REQUEST_SLOWLOG_TIMEOUT="2" 
PHP_PROCESS_CONTROL_TIMEOUT="60s"
PHP_PM="dynamic"
PHP_PM_MAX_CHILDREN="500"
PHP_PM_START_SERVERS="10"
PHP_PM_MIN_SPARE_SERVERS="10"
PHP_PM_MAX_SPARE_SERVERS="50"
PHP_PM_MAX_REQUESTS="102400"

# nginx vhost
NGINX_ROOT="/var/web/www/public" 
NGINX_CLIENT_MAX_BODY_SIZE="8m" 

# php larvael cache 
PHP_ENABLE_LARAVEL_CONFIG_CACHE="false"
```

## How to use
```
# run nginx or openresty
docker run -ti --rm \
  -e PARAMS=nginx \
  -e NGINX_ROOT="/var/web/www/public" \
  -e NGINX_CLIENT_MAX_BODY_SIZE="100m" \
  pristtlt/lnp-base:7.2-fpm-stretch

# run php-fpm
docker run -ti --rm \
  -e PARAMS=php \
  -e PHP_POST_MAX_SIZE="8M" \
  -e PHP_MAX_EXECUTION_TIME="600" \
  -e PHP_MAX_INPUT_TIME="600" \
  -e PHP_MEMORY_LIMIT="128M" \
  -e PHP_PROCESS_CONTROL_TIMEOUT="60s" \
  pristtlt/lnp-base:7.2-fpm-stretch

```

## thanks
- source code copy from: <https://github.com/shansongxian/docker>
- token-init.sh copy from:  <https://github.com/Kaggggggga/docker-php>

# PHP BASE IMAGE

`Be based on` [php official image](https://hub.docker.com/_/php)

## Include program

```
- php-fpm 7.*
- phpunit
- composer
- pecl
- openresty
```
## Default `WORKDIR`

```
WORKDIR /var/web/www
```

# PHP 7.0/7.1/7.2/7.3 modules

* `PHP 7.0/7.1 dose not include sodium lib`

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

# ENV
* Default ENV in `Dockerfile`
```
# WORKLOAD ARGS

# default is "" , can input nginx,php
PARAMS=""

# default php.ini conf
PHP_UPLOAD_MAX_FILESIZE="8M" 
PHP_POST_MAX_SIZE="8M" 
PHP_MAX_FILE_UPLOADS="20"
PHP_MAX_EXECUTION_TIME="600" 
PHP_MAX_INPUT_TIME="600" 
PHP_MEMORY_LIMIT="128M" 
## you can set date.timezone PHP_DATE_TIMEZONE="Asia/Shanghai"
PHP_DATE_TIMEZONE="UTC"

# default php-fpm conf
PHP_REQUEST_TERMINATE_TIMEOUT="65" 
PHP_REQUEST_SLOWLOG_TIMEOUT="2" 
PHP_PROCESS_CONTROL_TIMEOUT="60s"
PHP_PM="static"
PHP_PM_MAX_CHILDREN="15"
PHP_PM_START_SERVERS="2"
PHP_PM_MIN_SPARE_SERVERS="2"
PHP_PM_MAX_SPARE_SERVERS="8"
PHP_PM_MAX_REQUESTS="102400"

# default  nginx vhost
NGINX_ROOT="/srv/public" 
NGINX_CLIENT_MAX_BODY_SIZE="8m" 

# php larvael enable cache 
PHP_ENABLE_LARAVEL_CONFIG_CACHE="false"

# set php code dirscroty 777
# PHP_RW_DIRECTORY="${WORKDIR}/a,${WORKDIR}/b,${WORKDIR}/c"
# or PHP_RW_DIRECTORY="a,b,c"
# will set ${WORKDIR}/a ${WORKDIR}/b ${WORKDIR}/c 777
PHP_RW_DIRECTORY=""
```

# HOW TO USE

## Run container as workload

* Run openresty(nginx)

```
docker run -ti --rm \
  -e PARAMS=nginx \
  -e NGINX_ROOT="/var/web/www/public" \
  -e NGINX_CLIENT_MAX_BODY_SIZE="100m" \
  pristtlt/lnp-base:7.2-fpm-stretch
```

* Run dynamic php-fpm (by default)

```
docker run -ti --rm \
  -e PARAMS=php \
  -e PHP_POST_MAX_SIZE="8M" \
  -e PHP_MAX_EXECUTION_TIME="600" \
  -e PHP_RW_DIRECTORY="/srv/a,/srv/b,/srv/c" \
  pristtlt/lnp-base:7.2-fpm-stretch
```

* Run static php-fpm

```
docker run -ti --rm \
  -e PARAMS=php \
  -e PHP_PM="static" \
  -e PHP_PM_MAX_CHILDREN="20" \
  pristtlt/lnp-base:7.2-fpm-stretch
```


## Build image example 

* [demo project](https://github.com/winewei/php-docker-demo)

```
php-docker-demo/
├── Dockerfile
├── README.MD
├── composer.json
└── public
    └── index.php
```

* Docker file 

```
FROM pristtlt/lnp-base:7.2-fpm-stretch AS installer

COPY . .

RUN composer install

# build image
FROM pristtlt/lnp-base:7.2-fpm-stretch  AS build

COPY . .

RUN composer install --no-dev --no-progress -o
```

* build a image

```
docker built -t example:v1 .
```

# 
# Thanks
- <https://github.com/shansongxian/docker>
- <https://github.com/Kaggggggga/docker-php>

# Docker repo
[pristtlt/lnp-base](https://hub.docker.com/r/pristtlt/lnp-base)

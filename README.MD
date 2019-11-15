# PHP BASE IMAGE

`Be based on php official image`

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
# BUILD ARGS
# usually will be used to do some unit test,
# and build final image

## pull private repo
# git user
GIT_USER=""

# git password or private token
GIT_TOKEN=""

# git server scheme , default is https
GIT_HOST_SCHEME=""

# git service host, default is github.com
GIT_HOST=""

# composer auth token, in general, 
# used to pull private repo
COMPOSER_AUTH=""

#################################

# WORKLOAD ARGS

# default is "" , can input nginx,php
PARAMS=""

# default php.ini conf
PHP_UPLOAD_MAX_FILESIZE="8M" 
PHP_POST_MAX_SIZE="8M" 
PHP_MAX_EXECUTION_TIME="600" 
PHP_MAX_INPUT_TIME="600" 
PHP_MEMORY_LIMIT="128M" 

# default php-fpm conf
PHP_REQUEST_TERMINATE_TIMEOUT="65" 
PHP_REQUEST_SLOWLOG_TIMEOUT="2" 
PHP_PROCESS_CONTROL_TIMEOUT="60s"
PHP_PM="dynamic"
PHP_PM_MAX_CHILDREN="100"
PHP_PM_START_SERVERS="10"
PHP_PM_MIN_SPARE_SERVERS="10"
PHP_PM_MAX_SPARE_SERVERS="50"
PHP_PM_MAX_REQUESTS="102400"

# default  nginx vhost
NGINX_ROOT="/var/web/www/public" 
NGINX_CLIENT_MAX_BODY_SIZE="8m" 

# php larvael enable cache 
PHP_ENABLE_LARAVEL_CONFIG_CACHE="false"
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


## Build image

* demo project

```

```

* Docker file 

```
FROM pristtlt/lnp-base:7.2.19-fpm-stretch AS installer

ARG GIT_USER
ARG GIT_TOKEN
ARG GIT_HOST_SCHEME
ARG GIT_HOST

ENV GIT_USER=${GIT_USER} \
    GIT_TOKEN=${GIT_TOKEN} \
    GIT_HOST=${GIT_HOST} \
    GIT_HOST_SCHEME=${GIT_HOST_SCHEME}


# confirm initialize script run complete
RUN cat ~/.gitconfig

COPY . .

RUN composer install

# build image
FROM pristtlt/lnp-base:7.2.19-fpm-stretch  AS build

COPY . .

RUN composer install --no-dev --no-progress -o 
```

* build a image

```
docker built -t example:v1 \
--build-arg GIT_USER="test-bot" \
--build-arg GIT_TOKEN="xxxxx" \
.
```

# 
# Thanks
- <https://github.com/shansongxian/docker>
- <https://github.com/Kaggggggga/docker-php>

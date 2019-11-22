ARG IMAGE_TAG=${IMAGE_TAG:-7.2-fpm-stretch}
FROM php:${IMAGE_TAG}


# Install openresty
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        gettext-base \
        gnupg2 \
        lsb-release \
        software-properties-common \
        wget \
    && wget -qO /tmp/pubkey.gpg https://openresty.org/package/pubkey.gpg \
    && DEBIAN_FRONTEND=noninteractive apt-key add /tmp/pubkey.gpg \
    && rm /tmp/pubkey.gpg \
    && DEBIAN_FRONTEND=noninteractive add-apt-repository -y "deb http://openresty.org/package/debian $(lsb_release -sc) openresty" \
    && DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge \
        gnupg2 \
        lsb-release \
        software-properties-common \
        wget \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openresty \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /usr/local/openresty/nginx/conf/vhosts -p \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log


# Install composer & phpunit
RUN set -eux;\
    if [ ${PHP_VERSION%.*} =  7.0 ]; then \
        PHPUNIT_VERSION=6; \
    elif [ ${PHP_VERSION%.*} = 7.1 ]; then \
        PHPUNIT_VERSION=7; \
    elif [ ${PHP_VERSION%.*} =  7.2 ]; then \
        PHPUNIT_VERSION=8; \
    else \
        PHPUNIT_VERSION=8; \
    fi; \
    \
    curl -o /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar -L; \
    chmod +x /usr/local/bin/phpunit; \
    curl -o composer-setup.php https://getcomposer.org/installer -L; \
    php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer \
    rm -f composer-setup.php

# Enable php lib
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
                       libfcgi-bin \
                       unzip \
                       git \
                       gettext \
                       libxml2-dev \
                       zlib1g-dev \
                       libssl-dev \
                       libargon2-0 \
                       libpng-dev \
                       libjpeg-dev \
                       libzstd-dev \
                       libzip-dev \
    && docker-php-ext-install pdo_mysql \
                              bcmath \
                              pdo \
                              mbstring \
                              tokenizer \
                              ctype \
                              sockets \
                              json \
                              xmlrpc \
                              shmop \
                              sysvsem \
                              mysqli \
                              pcntl \
                              soap \
                              gettext \
                              zip \
                              exif \
                              opcache \
    && docker-php-ext-configure gd  --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd \
    && pecl install mongodb \
                    igbinary \
                    redis \
    && docker-php-ext-enable redis \
                             mongodb \
                             igbinary \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

# Install swoole lib
RUN set -eux; \
    if [ ${PHP_VERSION%.*} = 7.0 ]; then \
       # if PHP_VERSION is 7.0, the newest swoole version is 2.2.0
       yes Y | pecl install http://pecl.php.net/get/swoole-2.2.0.tgz; \
    else \
       yes Y | pecl install swoole; \
    fi; \
    \
    docker-php-ext-enable swoole

# conf template
COPY conf/conf-temp/. /conf-temp

COPY scripts/. /scripts

WORKDIR /srv

EXPOSE 80 9000

ENTRYPOINT ["/scripts/entrypoint.sh"]

ENV PARAMS="" \
    \
    PHP_UPLOAD_MAX_FILESIZE="8M" \
    PHP_POST_MAX_SIZE="8M" \
    PHP_MAX_FILE_UPLOADS="20" \
    PHP_MAX_EXECUTION_TIME="600" \
    PHP_MAX_INPUT_TIME="600" \
    PHP_MEMORY_LIMIT="128M" \
    PHP_DATE_TIMEZONE="UTC"
    \
    PHP_REQUEST_TERMINATE_TIMEOUT="65" \
    PHP_REQUEST_SLOWLOG_TIMEOUT="2" \
    PHP_PROCESS_CONTROL_TIMEOUT="60s" \
    PHP_PM="static" \
    PHP_PM_MAX_CHILDREN="15" \
    PHP_PM_START_SERVERS="2" \
    PHP_PM_MIN_SPARE_SERVERS="2" \
    PHP_PM_MAX_SPARE_SERVERS="8" \
    PHP_PM_MAX_REQUESTS="102400" \
    \
    NGINX_ROOT="/srv/public" \
    NGINX_CLIENT_MAX_BODY_SIZE="8m" \
    \
    PHP_ENABLE_LARAVEL_CONFIG_CACHE="false" \
    \
    PHP_RW_DIRECTORY=""
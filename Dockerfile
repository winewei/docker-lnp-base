ARG IMAGE_TAG=7.2-fpm-stretch

FROM php:${IMAGE_TAG}

ARG SWOOLE_VERSION="4.4.12"
ARG COMPOSER_VERSION="1.10.7"


RUN set -eux; \
    # Install openresty
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
                                                   ca-certificates \
                                                   gettext-base \
                                                   gnupg2 \
                                                   lsb-release \
                                                   software-properties-common \
                                                   wget; \
    wget -qO /tmp/pubkey.gpg https://openresty.org/package/pubkey.gpg; \
    apt-key add /tmp/pubkey.gpg; \
    add-apt-repository -y "deb http://openresty.org/package/debian $(lsb_release -sc) openresty"; \
    apt-get update; \
    apt-get install -y --no-install-recommends openresty; \
    rm /tmp/pubkey.gpg; \
    mkdir /usr/local/openresty/nginx/conf/vhosts -p; \
    rm -f /usr/local/openresty/nginx/conf/nginx.conf; \
    ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log; \
    ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log; \
    \
    \
    # Install composer & phpunit
    if [ ${PHP_VERSION%.*} =  7.0 ]; then \
        PHPUNIT_VERSION=6; \
    elif [ ${PHP_VERSION%.*} = 7.1 ]; then \
        PHPUNIT_VERSION=7; \
    elif [ ${PHP_VERSION%.*} =  7.2 ]; then \
        PHPUNIT_VERSION=8; \
    else \
        PHPUNIT_VERSION=9; \
    fi; \
    \
    curl -o /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar -L; \
    chmod +x /usr/local/bin/phpunit; \
    curl -o composer-setup.php https://getcomposer.org/installer -L; \
    php composer-setup.php --version=${COMPOSER_VERSION} --install-dir=/usr/local/bin/ --filename=composer; \
    rm -f composer-setup.php; \
    \
    \
    # Enable php lib
    apt-get update; \
    apt-get install -y --no-install-recommends \
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
                       libmemcached-dev \
                       libonig-dev \
                       libfreetype6-dev; \
    docker-php-ext-install pdo_mysql \
                           bcmath \
                           sockets \
                           shmop \
                           sysvsem \
                           mysqli \
                           pcntl \
                           soap \
                           gettext \
                           zip \
                           exif \
                           opcache; \
    # install freetype
    if [ ${PHP_VERSION%.*} =  8.0 ]; then \
       docker-php-ext-configure gd --enable-gd --with-freetype; \
    if [ ${PHP_VERSION%.*} =  7.4 ]; then \
       docker-php-ext-configure gd --enable-gd --with-freetype; \
    else \
      docker-php-ext-configure gd --with-freetype-dir; \
    fi; \
    docker-php-ext-install gd; \
    \
    # install xmlrpc
    if [ ${PHP_VERSION%.*} =  8.0 ]; then \
       pecl install http://pecl.php.net/get/xmlrpc-1.0.0RC2.tgz; \
       docker-php-ext-enable xmlrpc; \
    else \
       docker-php-ext-install xmlrpc; \
    fi; \
    \
    pecl install mongodb \
                 igbinary \
                 redis; \
    echo yes | pecl install memcached; \
    # Swoole PHP 4.5.9 released for PHP 8.0.0
    yes Y | pecl install http://pecl.php.net/get/swoole-${SWOOLE_VERSION}.tgz; \
    docker-php-ext-enable redis \
                          mongodb \
                          igbinary \
                          memcached \
                          swoole; \
    rm -f /usr/local/etc/php-fpm.conf; \
    rm -f /usr/local/etc/php/php.ini; \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove -y; \
    rm -rf /tmp/*; \
    rm -rf /var/lib/apt/lists/*

# conf template
COPY conf/conf-temp/. /conf-temp
COPY conf/conf-temp/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY conf/conf-temp/php.ini /usr/local/etc/php/php.ini

COPY scripts/. /scripts

WORKDIR /srv

EXPOSE 80 9000

ENTRYPOINT ["/scripts/entrypoint.sh"]

ENV PARAMS="" \

    ## php.ini config
    #[PHP]
    PHP_ENGINE="On" \
    PHP_SHORT_OPEN_TAG="Off" \
    PHP_PRECISION="14" \
    PHP_OUTPUT_BUFFERING="4096" \
    PHP_ZLIB_OUTPUT_COMPRESSION="Off" \
    PHP_IMPLICIT_FLUSH="Off" \
    PHP_UNSERIALIZE_CALLBACK_FUNC="" \
    PHP_SERIALIZE_PRECISION="-1" \
    #PHP_DISABLE_FUNCTIONS="passthru,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server" \
    PHP_DISABLE_FUNCTIONS="" \
    PHP_DISABLE_CLASSES="" \
    PHP_ZEND_ENABLE_GC="On" \
    PHP_EXPOSE_PHP="On" \
    PHP_MAX_EXECUTION_TIME="600" \
    PHP_MAX_INPUT_TIME="600" \
    PHP_MEMORY_LIMIT="256M" \
    PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT" \
    PHP_DISPLAY_ERRORS="Off" \
    PHP_DISPLAY_STARTUP_ERRORS="Off" \
    PHP_LOG_ERRORS="On" \
    PHP_LOG_ERRORS_MAX_LEN="1024" \
    PHP_IGNORE_REPEATED_ERRORS="Off" \
    PHP_IGNORE_REPEATED_SOURCE="Off" \
    PHP_REPORT_MEMLEAKS="On" \
    PHP_HTML_ERRORS="On" \
    PHP_VARIABLES_ORDER="GPCS" \
    PHP_REQUEST_ORDER="GP" \
    PHP_REGISTER_ARGC_ARGV="Off" \
    PHP_AUTO_GLOBALS_JIT="On" \
    PHP_POST_MAX_SIZE="100M" \
    PHP_AUTO_PREPEND_FILE="" \
    PHP_AUTO_APPEND_FILE="" \
    PHP_DEFAULT_MIMETYPE="text/html" \
    PHP_DEFAULT_CHARSET="UTF-8" \
    PHP_DOC_ROOT="" \
    PHP_USER_DIR="" \
    PHP_ENABLE_DL="Off" \
    PHP_FILE_UPLOADS="On" \
    PHP_UPLOAD_MAX_FILESIZE="100M" \
    PHP_MAX_FILE_UPLOADS="20" \
    PHP_ALLOW_URL_FOPEN="On" \
    PHP_ALLOW_URL_INCLUDE="Off" \
    PHP_DEFAULT_SOCKET_TIMEOUT="60" \
    #[CLI Server]
    PHP_CLI_SERVER="On" \
    #[Date]
    PHP_DATE_TIMEZONE="UTC" \
    #[Pdo_mysql]
    PHP_PDO_MYSQL_CACHE_SIZE="2000" \
    PHP_PDO_MYSQL_DEFAULT_SOCKET="" \
    #[mail function]
    PHP_SMTP="localhost" \
    PHP_SMTP_PORT="25" \
    PHP_MAIL_ADD_X_HEADER="Off" \
    #[ODBC]
    PHP_ODBC_ALLOW_PERSISTENT="On" \
    PHP_ODBC_CHECK_PERSISTENT="On" \
    PHP_ODBC_MAX_PERSISTENT="-1" \
    PHP_ODBC_MAX_LINKS="-1" \
    PHP_ODBC_DEFAULTLRL="4096" \
    PHP_ODBC_DEFAULTBINMODE="1" \
    #[Interbase]
    PHP_IBASE_ALLOW_PERSISTENT="1" \
    PHP_IBASE_MAX_PERSISTENT="-1" \
    PHP_IBASE_MAX_LINKS="-1" \
    PHP_IBASE_TIMESTAMPFORMAT="%Y-%m-%d %H:%M:%S" \
    PHP_IBASE_DATEFORMAT="%Y-%m-%d" \
    PHP_IBASE_TIMEFORMAT="%H:%M:%S" \
    #[MySQLi]
    PHP_MYSQLI_MAX_PERSISTENT="-1" \
    PHP_MYSQLI_ALLOW_PERSISTENT="On" \
    PHP_MYSQLI_MAX_LINKS="-1" \
    PHP_MYSQLI_CACHE_SIZE="2000" \
    PHP_MYSQLI_DEFAULT_PORT="3306" \
    PHP_MYSQLI_DEFAULT_SOCKET="" \
    PHP_MYSQLI_DEFAULT_HOST="" \
    PHP_MYSQLI_DEFAULT_USER="" \
    PHP_MYSQLI_DEFAULT_PW="" \
    PHP_MYSQLI_RECONNECT="Off" \
    #[mysqlnd]
    PHP_MYSQLND_COLLECT_STATISTICS="On" \
    PHP_MYSQLND_COLLECT_MEMORY_STATISTICS="Off" \
    #[PostgreSQL]
    PHP_PGSQL_ALLOW_PERSISTENT="On" \
    PHP_PGSQL_AUTO_RESET_PERSISTENT="Off" \
    PHP_PGSQL_MAX_PERSISTENT="-1" \
    PHP_PGSQL_MAX_LINKS="-1" \
    PHP_PGSQL_IGNORE_NOTICE="0" \
    PHP_PGSQL_LOG_NOTICE="0" \
    #[bcmath]
    PHP_BCMATH_SCALE="0" \
    #[Session]
    PHP_SESSION_SAVE_HANDLER="files" \
    PHP_SESSION_USE_STRICT_MODE="0" \
    PHP_SESSION_USE_COOKIES="1" \
    PHP_SESSION_USE_ONLY_COOKIES="1" \
    PHP_SESSION_NAME="PHPSESSID" \
    PHP_SESSION_AUTO_START="0" \
    PHP_SESSION_COOKIE_LIFETIME="0" \
    PHP_SESSION_COOKIE_PATH="/" \
    PHP_SESSION_COOKIE_DOMAIN="" \
    PHP_SESSION_COOKIE_HTTPONLY="" \
    PHP_SESSION_SERIALIZE_HANDLER="php" \
    PHP_SESSION_GC_PROBABILITY="1" \
    PHP_SESSION_GC_DIVISOR="1000" \
    PHP_SESSION_GC_MAXLIFETIME="1440" \
    PHP_SESSION_REFERER_CHECK="" \
    PHP_SESSION_CACHE_LIMITER="nocache" \
    PHP_SESSION_CACHE_EXPIRE="180" \
    PHP_SESSION_USE_TRANS_SID="0" \
    PHP_SESSION_SID_LENGTH="26" \
    PHP_SESSION_TRANS_SID_TAGS="a=href,area=href,frame=src,form=" \
    PHP_SESSION_SID_BITS_PER_CHARACTER="5" \
    #[Assertion]
    PHP_ZEND_ASSERTIONS="-1" \
    #[Tidy]
    PHP_TIDY_CLEAN_OUTPUT="Off" \
    #[soap]
    PHP_SOAP_WSDL_CACHE_ENABLED="1" \
    PHP_SOAP_WSDL_CACHE_DIR="/tmp" \
    PHP_SOAP_WSDL_CACHE_TTL="86400" \
    PHP_SOAP_WSDL_CACHE_LIMIT="5" \
    #[ldap]
    PHP_LDAP_MAX_LINKS="-1" \
    #[opcache]
    PHP_OPCACHE_ENABLE="1" \

    ## php-fpm config 
    PHP_ERROR_LOG="/proc/self/fd/2" \
    PHP_LOG_LEVEL="warning" \
    PHP_EMERGENCY_RESTART_THRESHOLD="10" \
    PHP_EMERGENCY_RESTART_INTERVAL="1m" \
    PHP_PROCESS_CONTROL_TIMEOUT="60s" \
    PHP_LISTEN="0.0.0.0:9000" \
    PHP_LISTEN_BACKLOG="8192" \
    PHP_LISTEN_OWNER="www-data" \
    PHP_LISTEN_GROUP="www-data" \
    PHP_LISTEN_MODE="0666" \
    PHP_USER="www-data" \
    PHP_GROUP="www-data" \
    PHP_PM="static" \
    PHP_PM_MAX_CHILDREN="15" \
    PHP_PM_START_SERVERS="2" \
    PHP_PM_MIN_SPARE_SERVERS="2" \
    PHP_PM_MAX_SPARE_SERVERS="8" \
    PHP_PM_MAX_REQUESTS="102400" \
    PHP_PM_STATUS_PATH="/php_status" \
    PHP_REQUEST_TERMINATE_TIMEOUT="65" \
    PHP_REQUEST_SLOWLOG_TIMEOUT="2" \
    PHP_ACCESS_LOG="/proc/self/fd/2" \
    PHP_SLOWLOG="/proc/self/fd/2" \
    PHP_RLIMIT_FILES="65535" \
    PHP_RLIMIT_CORE="0" \

    # nginx config
    NGINX_ROOT="/srv/public" \
    NGINX_CLIENT_MAX_BODY_SIZE="8m" \
    NGINX_FASTCGI_PASS="127.0.0.1:9000" \
    NGINX_KEEPALIVE_TIMEOUT="600s" \
    NGINX_CLIENT_HEADER_TIMEOUT="600s" \
    NGINX_CLIENT_BODY_TIMEOUT="600s" \
    NGINX_FASTCGI_CONNECT_TIMEOUT="600s" \
    NGINX_FASTCGI_SEND_TIMEOUT="600s" \
    NGINX_FASTCGI_READ_TIMEOUT="600s" \
    NGINX_ACCESS_LOG_FORMAT='[$time_local] " " \"$request\" " "  $status " " $request_time " "  $upstream_response_time " " $body_bytes_sent " " $http_referer " " \"$http_user_agent\" " " $remote_addr " " $http_x_forwarded_for' \

    # php application config
    PHP_ENABLE_LARAVEL_CONFIG_CACHE="false" \
    PHP_RW_DIRECTORY=""

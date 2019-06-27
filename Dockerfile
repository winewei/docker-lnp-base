FROM debian:stretch-slim

ARG RESTY_DEB_FLAVOR=""
ARG RESTY_DEB_VERSION="=1.13.6.2-1~stretch1"

# default will build php version: 7.2.18
ARG PHP_VERSION

ENV PHP_URL="https://www.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror"
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www --with-fpm-group=www --disable-cgi
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"
ENV PHP_INI_DIR /usr/local/etc/php

RUN set -eux; \
	{ \
		echo 'Package: php*'; \
		echo 'Pin: release *'; \
		echo 'Pin-Priority: -1'; \
	} > /etc/apt/preferences.d/no-debian-php

ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
		re2c

RUN useradd -M www -s /usr/sbin/nologin && apt-get update && apt-get install -y \
		$PHPIZE_DEPS \
		ca-certificates \
		curl \
		xz-utils \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
	[ ! -d /var/web/www ]; \
	mkdir -p /var/web/www; \
	chown www:www /var/web/www; \
	chmod 777 /var/web/www

RUN set -xe; \
	\
	fetchDeps=' \
		wget \
	'; \
	if ! command -v gpg > /dev/null; then \
		fetchDeps="$fetchDeps \
			dirmngr \
			gnupg \
		"; \
	fi; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	wget -O php.tar.xz "$PHP_URL"; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps

COPY docker-php-source /usr/local/bin/

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \

        apt-get install -y --no-install-recommends \
                libcurl4-openssl-dev \
                libedit-dev \
                libsodium-dev \
                libsqlite3-dev \
                libssl-dev \
                libxml2-dev \
                zlib1g-dev \
                libmcrypt-dev \
                libxml2-dev \
                libjpeg-dev \
                libpng-dev \
                argon2 \
                libargon2-0 \
                libargon2-0-dev \
		${PHP_EXTRA_BUILD_DEPS:-} \
	; \
	sed -e 's/stretch/buster/g' /etc/apt/sources.list > /etc/apt/sources.list.d/buster.list; \
	{ \
		echo 'Package: *'; \
		echo 'Pin: release n=buster'; \
		echo 'Pin-Priority: -10'; \
		echo; \
		echo 'Package: libargon2*'; \
		echo 'Pin: release n=buster'; \
		echo 'Pin-Priority: 990'; \
	} > /etc/apt/preferences.d/argon2-buster; \
	apt-get update; \
	apt-get install -y --no-install-recommends libargon2-dev; \
	rm -rf /var/lib/apt/lists/*; \
	\
	export \
		CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
	if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
	fi; \


        ./configure \
                --build="$gnuArch" \
                --with-config-file-path="$PHP_INI_DIR" \
                --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
                --enable-option-checking=fatal \
                --with-mhash \
                --enable-ftp \
                --enable-mbstring \
                --enable-mysqlnd \
                --with-password-argon2 \
                --with-sodium=shared \
                --with-curl \
                --with-libedit \
                --with-openssl \
                --with-zlib \
                --enable-fpm \
                --with-mysqli=mysqlnd \
                --with-pdo-mysql=mysqlnd \
                --with-iconv-dir \
                --with-jpeg-dir \
                --with-png-dir \
                --with-zlib \
                --enable-xml \
                --disable-rpath \
                --enable-bcmath \
                --enable-shmop \
                --enable-sysvsem \
                --enable-inline-optimization \
                --enable-exif \
                --with-curl \
                --enable-mbregex \
                --enable-mbstring \
                --with-openssl \
                --with-mhash \
                --enable-pcntl \
                --enable-sockets \
                --with-xmlrpc \
                --enable-zip \
                --enable-soap \
                --with-gettext \
                --with-gd \
                --enable-opcache \
		$(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit') \
		--with-libdir="lib/$debMultiarch" \
		${PHP_EXTRA_CONFIGURE_ARGS:-} \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
	make clean; \
	\
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\


	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	\
	php --version; \
	\
	pecl update-channels; \
    pecl install mongodb igbinary redis; \
	\
    curl -o swoole-4.3.4.tar.gz https://github.com/swoole/swoole-src/archive/v4.3.4.tar.gz -L; \
	tar xf swoole-4.3.4.tar.gz; \
	cd swoole-src-4.3.4; \
    	phpize; \
    	./configure --enable-coroutine --enable-openssl  --enable-http2  --enable-async-redis --enable-sockets --enable-mysqlnd --with-openssl-dir=/usr/include/openssl; \
		make clean; \
		make; \
		make install; \
		rm -rf swoole*; \
    \
	curl -o /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-8.phar -L; \
	chmod +x /usr/local/bin/phpunit; \
	\
	curl -o composer-setup.php https://getcomposer.org/installer -L; \
	php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /tmp/pear ~/.pearrc

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

RUN docker-php-ext-enable sodium mongodb redis swoole igbinary 

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
        openresty${RESTY_DEB_FLAVOR}${RESTY_DEB_VERSION} \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /usr/local/openresty${RESTY_DEB_FLAVOR}/nginx/conf/vhosts -p \
    && ln -sf /dev/stdout /usr/local/openresty${RESTY_DEB_FLAVOR}/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty${RESTY_DEB_FLAVOR}/nginx/logs/error.log

ENV PATH="$PATH:/usr/local/openresty${RESTY_DEB_FLAVOR}/luajit/bin:/usr/local/openresty${RESTY_DEB_FLAVOR}/nginx/sbin:/usr/local/openresty${RESTY_DEB_FLAVOR}/bin"
ENV PARAMS ""
RUN apt update \
    && apt install -y python3 unzip git\
    && curl -O https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && pip install awscli \
    && rm -rf ./get-pip.py \
    && DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge python3 \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY ./conf/default.conf /usr/local/openresty/nginx/conf/vhosts/default.conf
COPY ./conf/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY base/. /base

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/web/www

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000 80

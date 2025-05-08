ARG php_version
ARG alpine_version
ARG libstemmer_version

FROM php:${php_version}-fpm-alpine${alpine_version}

LABEL maintainer="Andrea Maccis <andrea.maccis@gmail.com>"

ARG php_version
ARG alpine_version
ARG libstemmer_version

ENV PHP_VERSION=${php_version}
ENV ALPINE_VERSION=${alpine_version}
ENV LIBSTEMMER_VERSION=${libstemmer_version}

ENV COMPOSER_VERSION=2.8.8
ENV DOCKER_PHP_EXTENSION_INSTALLER_VERSION=2.7.33

COPY Makefile /usr/src

RUN set -eux ; \
    # install virtual .build-deps \
    apk add --no-cache --virtual .build-deps \
            tar \
            perl \
            gcc \
            g++ \
            make ; \
    # install https://github.com/mlocati/docker-php-extension-installer \
    curl \
        --silent \
        --fail \
        --location \
        --retry 3 \
        --output /usr/local/bin/install-php-extensions \
        --url https://github.com/mlocati/docker-php-extension-installer/releases/download/$DOCKER_PHP_EXTENSION_INSTALLER_VERSION/install-php-extensions ; \
    echo "8481ae5d7c9f6d8bff2852bc460c4ce2f86d78bab9e3de6d82735adb78d9f92ceb97896f4e8afff1d042eec98ea1fa2f89cd740ffb9a76d365ab532915b32518  /usr/local/bin/install-php-extensions" | sha512sum -c ; \
    chmod +x /usr/local/bin/install-php-extensions ; \
    # install ffi \
    install-php-extensions ffi ; \
    # build libstemmer \
    mkdir -p /usr/src ; \
    cd /usr/src ; \
    curl -fsSL -o libstemmer_c.tar.gz https://snowballstem.org/dist/libstemmer_c-$LIBSTEMMER_VERSION.tar.gz ; \
    mkdir libstemmer_c ; \
    tar xfz /usr/src/libstemmer_c.tar.gz -C libstemmer_c --strip-components=1 ; \
    mv Makefile libstemmer_c ; \
    cd libstemmer_c ; \
    make ; \
    cp libstemmer.so /usr/lib ; \
    cd /usr/src ; \
    rm -rf libstemmer_c ; \
    rm /usr/src/libstemmer_c.tar.gz ; \
    # install composer \
    curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer \
        --version=$COMPOSER_VERSION ; \
    apk del --no-network .build-deps

WORKDIR /var/www

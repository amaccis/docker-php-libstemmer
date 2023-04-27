FROM php:8.1.18-fpm-alpine3.17

LABEL maintainer="Andrea Maccis <andrea.maccis@gmail.com>"

ARG libstemmer_version=2.2.0
ARG composer_version=2.5.5
ARG docker_php_extension_installer_version=2.1.20

ENV LIBSTEMMER_VERSION=${libstemmer_version}
ENV COMPOSER_VERSION=${composer_version}
ENV DOCKER_PHP_EXTENSION_INSTALLER_VERSION=${docker_php_extension_installer_version}

COPY Makefile /usr/src

RUN set -eux ; \
    # install https://github.com/mlocati/docker-php-extension-installer \
    curl \
        --silent \
        --fail \
        --location \
        --retry 3 \
        --output /usr/local/bin/install-php-extensions \
        --url https://github.com/mlocati/docker-php-extension-installer/releases/download/$DOCKER_PHP_EXTENSION_INSTALLER_VERSION/install-php-extensions ; \
    echo "98af76422af691b5a538886d131285c1ff9bca338d3b6f3c58f414e79222ca2c75eeaf89a0f654bf1ce54a69eee3843d09fa39551956859fd132d8aa394eafe9  /usr/local/bin/install-php-extensions" | sha512sum -c ; \
    chmod +x /usr/local/bin/install-php-extensions ; \
    # install ffi \
    install-php-extensions ffi ; \
    apk add --no-cache --virtual .build-deps \
            curl \
            tar \
            perl \
            gcc \
            g++ \
            make ; \
    # build libstemmer \
    mkdir -p /usr/src ; \
    cd /usr/src ; \
    curl -fsSL -o libstemmer_c.tar.gz https://snowballstem.org/dist/libstemmer_c-$LIBSTEMMER_VERSION.tar.gz ; \
    echo "a61a06a046a6a5e9ada12310653c71afb27b5833fa9e21992ba4bdf615255de991352186a8736d0156ed754248a0ffb7b7712e8d5ea16f75174d1c8ddd37ba4a  /usr/src/libstemmer_c.tar.gz" | sha512sum -c ; \
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

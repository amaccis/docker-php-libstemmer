FROM php:8.0.12-fpm-alpine3.14

LABEL maintainer="Andrea Maccis <andrea.maccis@gmail.com>"

ARG libstemmer_version=2.2.0
ARG composer_version=2.1.12

ENV LIBSTEMMER_VERSION=${libstemmer_version}
ENV COMPOSER_VERSION=${composer_version}

COPY Makefile /usr/src

RUN set -eux ; \
    # install https://github.com/mlocati/docker-php-extension-installer
    curl \
        --silent \
        --fail \
        --location \
        --retry 3 \
        --output /usr/local/bin/install-php-extensions \
        --url https://github.com/mlocati/docker-php-extension-installer/releases/download/1.4.2/install-php-extensions ; \
    echo "a4d70bd93902c95ab2c2409dc9571b6df8f7c314f3974c8c5b9a7751ada0b545287e9a3ef55effe0e5a0b94e0e160645bcfcbd73cd18c83e7293bb770c028d2a  /usr/local/bin/install-php-extensions" | sha512sum -c ; \
    chmod +x /usr/local/bin/install-php-extensions ; \
    # install ffi
    install-php-extensions ffi ; \
    apk add --no-cache --virtual .build-deps \
            curl \
            tar \
            perl \
            gcc \
            g++ \
            make ; \
    # build libstemmer
    mkdir -p /usr/src ; \
    cd /usr/src ; \
    curl -fsSL -o libstemmer_c-$LIBSTEMMER_VERSION.tar.gz https://snowballstem.org/dist/libstemmer_c-$LIBSTEMMER_VERSION.tar.gz ; \
    tar xfz /usr/src/libstemmer_c-$LIBSTEMMER_VERSION.tar.gz ; \
    mv Makefile libstemmer_c-$LIBSTEMMER_VERSION ; \
    cd libstemmer_c-$LIBSTEMMER_VERSION ; \
    make ; \
    cp libstemmer.so /usr/lib ; \
    cd /usr/src ; \
    rm -rf libstemmer_c-$LIBSTEMMER_VERSION ; \
    rm /usr/src/libstemmer_c-$LIBSTEMMER_VERSION.tar.gz ; \
    # install composer
    curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer \
        --version=$COMPOSER_VERSION ; \
    apk del --no-network .build-deps

WORKDIR /var/www

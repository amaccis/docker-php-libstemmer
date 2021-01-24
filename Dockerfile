FROM php:8.0.1-fpm-alpine3.13

LABEL maintainer="Andrea Maccis <andrea.maccis@gmail.com>"

ENV LIBSTEMMER_VERSION 2.1.0
ENV COMPOSER_VERSION 2.0.8

ENV LIBSTEMMER_DIRECTORY "libstemmer_c-${LIBSTEMMER_VERSION}"
ENV LIBSTEMMER_FILENAME "${LIBSTEMMER_DIRECTORY}.tar.gz"
ENV LIBSTEMMER_URL "https://snowballstem.org/dist/${LIBSTEMMER_FILENAME}"
ENV COMPOSER_URL "https://getcomposer.org/installer"

COPY Makefile /usr/src

RUN apk add libffi \
            libffi-dev; \
    docker-php-ext-install ffi

RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
            curl \
            tar \
            perl \
            gcc \
            g++ \
            make; \
    # libstemmer
    mkdir -p /usr/src; \
    cd /usr/src; \
    curl -fsSL -o $LIBSTEMMER_FILENAME $LIBSTEMMER_URL; \
    tar xfz /usr/src/$LIBSTEMMER_FILENAME; \
    mv Makefile $LIBSTEMMER_DIRECTORY; \
    cd $LIBSTEMMER_DIRECTORY; \
    make; \
    cp libstemmer.so /usr/lib; \
    cd /usr/src; \
    rm -rf $LIBSTEMMER_DIRECTORY; \
    rm $LIBSTEMMER_FILENAME; \
    # composer
    curl -sS $COMPOSER_URL | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer \
        --version=$COMPOSER_VERSION; \
    apk del --no-network .build-deps;

WORKDIR /var/www

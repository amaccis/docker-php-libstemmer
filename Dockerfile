FROM php:7.4.3-fpm-alpine3.11

LABEL maintainer="Andrea Maccis <andrea.maccis@gmail.com>"

ENV LIBSTEMMER_URL "https://snowballstem.org/dist/libstemmer_c.tgz"

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
    curl -fsSL -o libstemmer_c.tgz $LIBSTEMMER_URL; \
    tar xfz /usr/src/libstemmer_c.tgz; \
    mv Makefile libstemmer_c; \
    cd libstemmer_c; \
    make; \
    cp libstemmer.so /usr/lib; \
    cd /usr/src; \
    rm -rf libstemmer_c; \
    rm libstemmer_c.tgz; \
    apk del --no-network .build-deps

WORKDIR /var/www

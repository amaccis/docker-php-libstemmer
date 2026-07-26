ARG php_version=8.2.31
ARG alpine_version=3.23
ARG libstemmer_version

FROM php:${php_version}-fpm-alpine${alpine_version}

LABEL org.opencontainers.image.authors="Andrea Maccis <andrea.maccis@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/amaccis/docker-php-libstemmer"
LABEL org.opencontainers.image.description="PHP Alpine image with FFI extension and libstemmer compiled as shared library"
LABEL org.opencontainers.image.licenses="MIT"

ARG php_version
ARG alpine_version
ARG libstemmer_version

ENV PHP_VERSION=${php_version}
ENV ALPINE_VERSION=${alpine_version}
ENV LIBSTEMMER_VERSION=${libstemmer_version}

ENV COMPOSER_VERSION=2.9.8
ENV DOCKER_PHP_EXTENSION_INSTALLER_VERSION=2.11.1

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
    echo "ca45e43f4299997f3cc78459eb7cc29c125281db8779f99209dc3fe3298fd117  /usr/local/bin/install-php-extensions" | sha256sum -c ; \
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

#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: missing first argument (PHP_VERSION)."
  exit 1
fi

if [ -z "$2" ]; then
  echo "Error: missing second argument (ALPINE_VERSION)."
  exit 1
fi

if [ -z "$3" ]; then
  echo "Error: missing third argument (LIBSTEMMER_VERSION)."
  exit 1
fi

PHP_VERSION="$1"
ALPINE_VERSION="$2"
LIBSTEMMER_VERSION="$3"

IMAGE_VERSION="$PHP_VERSION-$LIBSTEMMER_VERSION"
IMAGE_TAG="amaccis/php-libstemmer:$IMAGE_VERSION"

docker build -t $IMAGE_TAG \
  --build-arg php_version=$PHP_VERSION \
  --build-arg alpine_version=$ALPINE_VERSION \
  --build-arg libstemmer_version=$LIBSTEMMER_VERSION .

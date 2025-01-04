#!/bin/bash

IMAGE_VERSION="8.4.2-2.2.0"
IMAGE_TAG=amaccis/php-libstemmer:$IMAGE_VERSION

docker build -t $IMAGE_TAG .

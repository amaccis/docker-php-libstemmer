#!/bin/bash

IMAGE_VERSION="8.1.18-2.2.0"
IMAGE_TAG=amaccis/php-libstemmer:$IMAGE_VERSION

docker build -t $IMAGE_TAG .

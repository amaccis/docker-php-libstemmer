# amaccis/php-libstemmer

The purpouse of this image is to provide an Alpine Linux environment with PHP 7.4 onboard, its [FFI](https://www.php.net/manual/en/book.ffi.php) extension enabled and the [libstemmer](https://snowballstem.org/dist/libstemmer_c.tgz) compiled as a shared library. Besides, [composer](https://getcomposer.org) is included.

# Snowball and libstemmer

[Snowball](https://snowballstem.org/) is a small string processing language designed for creating stemming algorithms for use in Information Retrieval.
[Libstemmer](https://snowballstem.org/dist/libstemmer_c.tgz) instead, contains a complete set of Snowball stemming algorithms that you can include into a C project of your own. With libstemmer you don't need to use the Snowball compiler.

# How to use this image

## Using docker
```bash
$ docker run --name php-libstemmer -v $PWD/:/var/www -d amaccis/php-libstemmer
```

## Using docker-compose
```yaml
version: '3.7'

services:
  php-fpm:
    image: amaccis/php-libstemmer
    working_dir: /var/www
    volumes:
      - ./:/var/www
```

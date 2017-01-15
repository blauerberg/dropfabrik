# Drupal on Docker

This is a example configurations to help development more speedy for Drupal.
You can choose 3 example configration according to amount of resource in your machine, and will be able to build a Drupal environment on Docker in 5 to 10 minutes with the following steps.

## Quick start

First, get a example configuration.
```bash
$ git clone https://github.com/blauerberg/drupal-on-docker.git
$ cd drupal-on-docker
```

This git repository has 3 example configration according to amount of resource in the host machine.

- example-tiny: less than 8GB ram
- example: less than 16GB ram
- example-huge: more than 16GB ram

For example, if you use a windows/OS X with 8GB ram, you should use "example-tiny" configuration.
```bash
$ cd example-tiny
```

Next, create a directory to mount source code of drupal.
```bash
$ mkdir volumes
$ curl https://ftp.drupal.org/files/projects/drupal-X.YY.tar.gz | tar zx --strip=1 -C volumes/drupal
$ mv drupal-X.yy drupal
```

create & start containers.
```bash
$ docker-compose up -d
```

if you use linux host, you have to fix permissions for your drupal directory with:
```bash
$ docker-compose exec php chown -R www-data:www-data /var/www/html/sites/default
```

access your drupal site!
```bash
$ open http://localhost
```

### Example of docker-compose.yml for Quick start
```
version: '2'

services:
  datastore:
    image: busybox
    volumes:
      # put your drupal source code and mount as volume.
      - ./volumes/drupal:/var/www/html
    container_name: drupal_datastore
  mysql:
    image: mariadb:10.1
    volumes_from:
      - datastore
    volumes:
      # override mysql config if necessary.
      - ./mysql/server.cnf:/etc/mysql/conf.d/server.cnf
      # It is also possible to save mysql files to on host filesystem.
      # - ./volumes/mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: drupal
      MYSQL_USER: drupal
      MYSQL_PASSWORD: drupal
    ports:
      - "3306:3306"
    container_name: drupal_mysql
  php:
    image: blauerberg/drupal-php:7.0-fpm
    volumes_from:
      - datastore
    volumes:
      # allocate large memory_limit for drush.
      - ./php/php.ini:/usr/local/etc/php/php.ini
      # override php-fpm config to use xdebug with port 9000.
      - ./php/www.conf:/usr/local/etc/php-fpm.d/www.conf
      - ./php/zz-docker.conf:/usr/local/etc/php-fpm.d/zz-docker.conf
    links:
      - mysql
    container_name: drupal_php
  nginx:
    image: nginx:1.10
    links:
      - php
    volumes_from:
      - datastore
    volumes:
      # override nginx config to execute drupal through the php container.
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "80:80"
    container_name: drupal_nginx
```

## License

MIT

# Drupal on Docker

This is a example configurations to help development more speedy for Drupal.
You can choose 3 example configration according to amount of resource in your machine, and will be able to build a Drupal environment on Docker in 5 to 10 minutes with the following steps.

## Overview

Example configuration includes the following containers:

| Container | Service name | Image | Exposed port |
| --------- | ------------ | ----- | ------------ |
| Nginx | web | <a href="https://hub.docker.com/_/nginx/" target="_blank">nginx</a> | 80 |
| MariaDB | db | <a href="https://hub.docker.com/_/mariadb/" target="_blank">mariadb</a> | 3306 |
| PHP-FPM 5.6 / 7.0 | php | <a href="https://hub.docker.com/r/blauerberg/drupal-php/" target="_blank">blauerberg/drupal-php</a> | 9000 (for Xdebug) |

## Getting started

First, get a example configurations.
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

Access your drupal site.
```bash
$ open http://localhost # or open http://localhost on your browser.
```

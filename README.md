# Drupal on Docker

This is a example configurations to help development more speedy for Drupal.
You can choose 3 example configration according to amount of resource in your machine, and will be able to build a Drupal environment on Docker in 5 to 10 minutes with the following steps.

日本語のREADMEは[こちら](https://github.com/blauerberg/drupal-on-docker/blob/master/README_ja.md)

## Overview

Example configuration includes the following containers:

| Container | Service name | Image | Exposed port |
| --------- | ------------ | ----- | ------------ |
| Nginx | web | <a href="https://hub.docker.com/_/nginx/" target="_blank">nginx</a> | 80 |
| MariaDB | db | <a href="https://hub.docker.com/_/mariadb/" target="_blank">mariadb</a> | 3306 |
| PHP-FPM 5.6 / 7.0 | php | <a href="https://hub.docker.com/r/blauerberg/drupal-php/" target="_blank">blauerberg/drupal-php</a> | 9000 (for Xdebug) |

## Prerequisites

- Lastest version of [Docker for MAC](https://docs.docker.com/docker-for-mac/) on macOS Sierra
- Lastest version of [Docker for Windows](https://docs.docker.com/docker-for-windows/) on Windows 10
- Lastest version of [Docker engine](https://docs.docker.com/engine/installation/linux/ubuntulinux/) on linux
- If you use Docker for Windows, [enable shared drives](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/)

## Getting started

### Start containers

First, get a example configurations.
```bash
$ git clone https://github.com/blauerberg/drupal-on-docker.git
$ cd drupal-on-docker
```

This git repository has 3 example configration according to amount of resource in the host machine.

- [example-tiny](https://github.com/blauerberg/drupal-on-docker/tree/master/example-tiny): less than 8GB ram
- [example](https://github.com/blauerberg/drupal-on-docker/tree/master/example): less than 16GB ram
- [example-huge](https://github.com/blauerberg/drupal-on-docker/tree/master/example-huge): more than 16GB ram

For example, if you use a windows/OS X with 8GB ram, you should use "example-tiny" configuration.
```bash
$ cd example-tiny
```

Next, create a directory to mount source code of Drupal.
```bash
$ mkdir volumes
```

download & extract Drupal source code.
```bash
# Note: replace "X.Y.Z" in below to  Drupal's version you'd like to use.
$ curl https://ftp.drupal.org/files/projects/drupal-X.Y.Z.tar.gz | tar zx --strip=1 -C volumes/drupal
```

create & start containers.
```bash
$ docker-compose up -d
```

if you use Linux host, you have to fix permissions for your Drupal directory with:
```bash
$ docker-compose exec php chown -R www-data:www-data /var/www/html/sites/default
```

Access your Drupal site.
```bash
$ open http://localhost # or open http://localhost on your browser.
```

### Install Drupal

Credentials of database is configured in docker-compose.yml.
Default value is below:

- Database Name: `drupal`
- Username: `drupal`
- Password: `drupal`

Please see also "Environment Variables" section in https://hub.docker.com/_/mariadb/

In this container set, nginx, mariadb and php-fpm run on the separate containers.
Therefore, please note that hostname of database server when installing Drupal is `db`, not `localhost`.

Instead of the installation wizard, you can install Drupal using Drush as follows:

```bash
$ docker-compose exec php drush -y --root="/var/www/html" site-install standard --site-name="Drupal on Docker" --account-name="drupal" --account-pass="drupal" --db-url="mysql://drupal:drupal@db/drupal"
```

## Other tips

### Access inside the containers

You should use `docker-compose exec` instead of ssh.

```bash
$ docker-compose exec {Service name} /bin/bash
# ex. docker-compose exec php /bin/bash
```

### Use Drush

Drush is installed in php container.

```bash
$ docker-compose exec php drush st
```

### Connect database

Via Drush:
```bash
$ docker-compose exec php drush sql-cli
```

Database container is exposing port 3306 on 127.0.0.1. So you can access database in the container from GUI application on Host OS such as [MysqlWorkbench](https://www.mysql.com/products/workbench/), [Sequel Pro](https://www.sequelpro.com/).

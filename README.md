# Drop Fabrik

"Drop Fabrik" is configuration of Docker to help development more speedy for Drupal.
You will be able to build a Drupal environment on Docker in 5 to 10 minutes with the following steps.

日本語のREADMEは[こちら](https://github.com/blauerberg/dropfabrik/blob/master/README_ja.md)

## Overview

Example configuration includes the following containers:

| Container | Service name | Image | Exposed port |
| --------- | ------------ | ----- | ------------ |
| Nginx Proxy | nginx-proxy | <a href="https://hub.docker.com/r/jwilder/nginx-proxy/" target="_blank">jwilder/nginx-proxy</a> | 80 |
| Nginx | web | <a href="https://hub.docker.com/_/nginx/" target="_blank">nginx</a> | |
| MariaDB | db | <a href="https://hub.docker.com/_/mariadb/" target="_blank">mariadb</a> | 3306 |
| PHP-FPM 5.6 / 7.0 / 7.1 | php | <a href="https://hub.docker.com/r/blauerberg/drupal-php/" target="_blank">blauerberg/drupal-php</a> | |
| mailhog | mailhog | <a href="https://hub.docker.com/r/mailhog/mailhog/" target="_blank">mailhog/mailhog</a> | 8025 (HTTP server) |
| phpmyadmin | phpmyadmin | <a href="https://hub.docker.com/r/phpmyadmin/phpmyadmin/" target="_blank">phpmyadmin/phpmyadmin</a> | 8080 (HTTP server) |

## Prerequisites

- Lastest version of [Docker for MAC](https://docs.docker.com/docker-for-mac/) on macOS Sierra
- Lastest version of [Docker for Windows](https://docs.docker.com/docker-for-windows/) on Windows 10
- Lastest version of [Docker engine](https://docs.docker.com/engine/installation/linux/ubuntulinux/) on linux
- If you use Docker for Windows, [enable shared drives](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/)

## Getting started

### Start containers

First, get a configurations.
```bash
$ git clone https://github.com/blauerberg/dropfabrik.git
$ cd dropfabrik
```

Next, create a directory to mount source code of Drupal.
```bash
$ mkdir -p volumes/drupal
```

download & extract Drupal source code.
```bash
# Note: replace "X.Y.Z" in below to  Drupal's version you'd like to use.
$ curl https://ftp.drupal.org/files/projects/drupal-X.Y.Z.tar.gz | tar zx --strip=1 -C volumes/drupal
```

If you use macOS, highly recommend using [docker-sync](https://github.com/EugenMayer/docker-sync/) to avoid [performance problems](https://github.com/docker/for-mac/issues/77). please see [Use docker-sync](#use-docker-sync).

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

Credentials of database is configured in docker-compose.override.yml.
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
$ docker-compose exec php drush -y config-set system.theme admin bartik
```

## Stop containers

```
$ docker-compose stop
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

### Restore database from existing site

Put gzipped sql dump as `initdb.sql.gz` and uncomment below line at `docker-compose.override.yml`.
It will be loaded by mariadb and will restore once only at generating the container.

```
- ./initdb.sql.gz:/docker-entrypoint-initdb.d/initdb.sql.gz
```

### Connect database

Via Drush:
```bash
$ docker-compose exec php drush sqlc
```

Database container is exposing port 3306 on 127.0.0.1. So you can access database in the container from GUI application on Host OS such as [MysqlWorkbench](https://www.mysql.com/products/workbench/), [Sequel Pro](https://www.sequelpro.com/).

### Use docker-sync

If you use macOS, highly recommend installing [docker-sync](https://github.com/EugenMayer/docker-sync/) as follows to avoid [performance problems](https://github.com/docker/for-mac/issues/77).

If you use docker-sync please copy `docker-compose.override-for-docker-sync.yml` as` docker-compose.override.yml`.
Also, you need to run the image with `docker-sync-stack` instead of` docker-compose`.

```bash
$ docker-sync-stack start
```

Please see also: https://github.com/EugenMayer/docker-sync/wiki

## Supporting Organizations
- https://annai.co.jp

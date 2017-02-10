# Drop Fabrik

"Drop Fabrik" is configuration of Docker to help development more speedy for Drupal.
You can choose 3 configration according to amount of resource in your machine, and will be able to build a Drupal environment on Docker in 5 to 10 minutes with the following steps.

日本語のREADMEは[こちら](https://github.com/blauerberg/dropfabrik/blob/master/README_ja.md)

## Overview

Example configuration includes the following containers:

| Container | Service name | Image | Exposed port |
| --------- | ------------ | ----- | ------------ |
| Nginx | web | <a href="https://hub.docker.com/_/nginx/" target="_blank">nginx</a> | 80 |
| MariaDB | db | <a href="https://hub.docker.com/_/mariadb/" target="_blank">mariadb</a> | 3306 |
| PHP-FPM 5.6 / 7.0 / 7.1 | php | <a href="https://hub.docker.com/r/blauerberg/drupal-php/" target="_blank">blauerberg/drupal-php</a> | 9000 (for Xdebug) |

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

This git repository has 3 configurations according to amount of resource in the host machine.

- [tiny](https://github.com/blauerberg/dropfabrik/tree/master/tiny): less than 8GB ram
- [standard](https://github.com/blauerberg/dropfabrik/tree/master/standard): less than 16GB ram
- [huge](https://github.com/blauerberg/dropfabrik/tree/master/huge): more than 16GB ram

For example, if you use a windows/macOS with 8GB ram, you should use "tiny" configuration.
```bash
$ cd tiny
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

Note: `docker-compose` command must be executed in the directory containing `docker-compose.yml`.

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
$ docker-compose exec php drush sql-cli
```

Database container is exposing port 3306 on 127.0.0.1. So you can access database in the container from GUI application on Host OS such as [MysqlWorkbench](https://www.mysql.com/products/workbench/), [Sequel Pro](https://www.sequelpro.com/).

### Use docker-sync

If you use macOS, highly recommend installing [docker-sync](https://github.com/EugenMayer/docker-sync/) as follows to avoid [performance problems](https://github.com/docker/for-mac/issues/77).
```bash
$ gem install docker-sync
$ brew install fswatch
```

Also you have to some changes into `docker-compose.override.yml`.

- comment out `volumes_from` block (2 places):
```
# volumes_from:
# - datastore
```

- uncomment `drupal_source` block (2 places):

```
# Replace volume to this to use docker-sync for mac OS users to resolve performance issue.
# See also: https://github.com/docker/for-mac/issues/77
- drupal_source:/var/www/html:rw
```

- uncomment `volumes` block at the bottom
```
volumes:
  drupal_source:
    external: true
```

Start the synchronization with `docker-sync` command
```bash
$ docker-sync start
```

Finally, start container in new shell.
```bash
$ docker-compose up -d
```

Alternatively, you can also run `docker-sync start` and `docker-compose up` together.

```bash
$ docker-sync-stack start
```

Please see also: https://github.com/EugenMayer/docker-sync/wiki

### Deploy to production environment (example)

You can also deploy this container set to production environment such as Amazon EC2.
For example, to deploy Amazon EC2, you can following instruction below.

First, create your docker engine on Amazon EC2.
```
$ docker-machine create --driver amazonec2 --amazonec2-instance-type t2.large --amazonec2-region ap-northeast-1 --amazonec2-zone c dropfabrik
```

Note: in default, this instance use security group named `docker-machine` and it will be rejected any http traffic. So you have to change setting of the security group to accept http.

And Then, set the environment variables to use remote docker engine.
```
eval $(docker-machine env dropfabrik)
```

Next, download your drupal code and database dump.
```
$ git clone https://github.com/blauerberg/dropfabrik.git
$ cd dropfabrik/standard

# download your drupal code.
$ mkdir volumes
$ git clone {YOUR_GIT_REPO_URI} volumes/drupal
# copy your database dump of existing site as mysql/initdb.sql.gz
$ cp /some/path/your_site_db.sql.gz mysql/initdb.sql.gz

or download vanila drupal to launch new site

$ mkdir -p volumes/drupal
$ curl https://ftp.drupal.org/files/projects/drupal-X.Y.Z.tar.gz | tar zx --strip=1 -C volumes/drupal
# if you want to install drupal with your language, you have to create sites/default/files/translation dir.
$ mkdir -p volumes/drupal/sites/default/files/translations
```

Finally, build your docker image and deploy it.
```
$ docker-compose -f docker-compose.yml -f docker-compose.production.yml up --build
```

Note: Note: `docker-compose.production.yml` is an example configuration for simple use case.

## Supporting Organizations
- https://annai.co.jp

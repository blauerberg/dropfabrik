#!/bin/bash

function drush8_sa() {
  docker-compose exec php drush sa
}

function drush8_sql_sync() {
  docker-compose exec php drush -y sql-sync $1 @self
  fix_permission_for_drush8
}

function drush8_rsync() {
  docker-compose exec php drush -y rsync $1:%files @self:%files
  fix_permission_for_drush8
}

function drush8_cc() {
  docker-compose exec php drush -y cc all
}

function drush9_sa() {
  docker-compose exec php vendor/bin/drush sa
}

function drush9_sql_sync() {
  docker-compose exec php vendor/bin/drush -y sql:sync $1 @self
  fix_permission_for_drush9
}

function drush9_rsync() {
  docker-compose exec php vendor/bin/drush -y rsync $1:%files @self:%files
  fix_permission_for_drush9
}

function drush9_cc() {
  docker-compose exec php vendor/bin/drush -y cr
}

function fix_permission_for_drush8() {
  if [[ $OSTYPE == linux* ]]; then
    docker-compose exec php chown -R www-data:www-data /var/www/html/sites/default/files
  fi
}

function fix_permission_for_drush9() {
  if [[ $OSTYPE == linux* ]]; then
    docker-compose exec php chown -R www-data:www-data /var/www/html/web/sites/default/files
  fi
}

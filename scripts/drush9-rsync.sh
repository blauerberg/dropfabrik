#!/bin/sh

source $(dirname $0)/common.sh

if [ $# -ne 1 ]; then
  cat <<_EOT_
Usage:
  $0 source

Description:
  Do drush rsync to @self by drush v9.
  You can show available "source" by "drush9_sa.sh".
  If your project is created by the Drupal 7, please use drush8-rsync.sh.

_EOT_
  exit -1
fi

drush9_rsync $1

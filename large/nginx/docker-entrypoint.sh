#!/bin/sh

chown -R www-data:www-data /var/www/html
nginx -g "daemon off;"

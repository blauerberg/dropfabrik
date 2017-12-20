FROM blauerberg/drupal-php:7.0-fpm
#FROM blauerberg/drupal-php:7.1-fpm
#FROM blauerberg/drupal-php:5.6-fpm

COPY php/php.ini /usr/local/etc/php/php.ini
COPY php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

FROM blauerberg/drupal-php:7.1-fpm

# workaround for https://github.com/docker/for-win/issues/167
RUN mkdir -p /root/.ssh
RUN chmod 700 /root/.ssh
COPY id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

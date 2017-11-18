#!/usr/bin/env sh

set -x

MEM=${PHP_MEM:=256M}

sed -i 's/memory_limit.*$/memory_limit = '$MEM'/g' /etc/php7/php.ini
sed -i 's/memory_limit.*$/memory_limit = '$MEM'/g' /etc/php7/php-fpm.conf

mkdir -p /run/php
mkdir -p /var/run/php
php-fpm7 --nodaemonize
php-fpm --nodaemonize


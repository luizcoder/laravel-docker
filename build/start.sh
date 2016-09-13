#!/bin/bash

/usr/local/bin/mysql-run &
php5-fpm -c /etc/php5/fpm  &
nginx

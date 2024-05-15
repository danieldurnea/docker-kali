#!/bin/bash
#
# 60_php82-fpm.sh
#

SERVICE=php8.2-fpm

if test -f "/etc/init.d/$SERVICE"; then
    /etc/init.d/$SERVICE start
fi

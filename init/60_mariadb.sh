#!/bin/bash
#
# 60_mariadb.sh
#

SERVICE=mariadb

if test -f "/etc/init.d/$SERVICE"; then
    /etc/init.d/$SERVICE start
fi

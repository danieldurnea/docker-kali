#!/bin/bash
#
# 20_postgres.sh
#

SERVICE=postgres

if test -f "/etc/init.d/$SERVICE"; then
    /etc/init.d/$SERVICE start
fi

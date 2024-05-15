#!/bin/bash
#
# 80_juice-shop.sh
#

SERVICE=juice-shop

if test -f "/etc/init.d/$SERVICE"; then
    /etc/init.d/$SERVICE start
fi

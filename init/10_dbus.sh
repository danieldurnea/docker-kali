#!/bin/bash
#
# 10_dbus.sh
#

SERVICE=dbus

if test -f "/etc/init.d/$SERVICE"; then
    /etc/init.d/$SERVICE start
fi

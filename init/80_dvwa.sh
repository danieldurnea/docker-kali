#!/bin/bash
#
# 60_dvwa.sh
#

SERVICE=dvwa

if test -f "/etc/init.d/$SERVICE"; then
    /etc/init.d/$SERVICE start
fi

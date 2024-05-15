#!/bin/bash
#
# 90_fix_kail_home
#

folder_path="/home/kali"

desired_user="kali"
desired_group="kali"

current_user=$(stat -c '%U' "$folder_path")
current_group=$(stat -c '%G' "$folder_path")

if [ "$current_user" != "$desired_user" ] || [ "$current_group" != "$desired_group" ]; then
    chown $desired_user:$desired_group "$folder_path"
fi

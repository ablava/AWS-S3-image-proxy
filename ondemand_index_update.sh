#!/bin/bash

if [[ $(/home/centos/check_update_requests.sh) ]]; then
    /home/centos/make_html.sh `date -d "today 13:00" '+%Y-%m-%d'`
fi

#!/bin/bash

date=$(date -d "3 minutes ago" +"%s")

tail -100 /var/log/nginx/access.log | (
while read line; do
[ `date -d"$(echo $line | cut -d' ' -f4 | sed -e 's/.*\[//;s/\// /g;s/:/ /;')" +"%s"` -ge $date ] && echo $line
done) | grep update.html

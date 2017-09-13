#!/bin/sh

# Script to upload images to S3
# It can be scheduled to run every minute to upload new files only
# Replace [BUCKET] with your S3 bucket below

myFunction() {
    while read -r file; do
    /usr/local/bin/aws s3 cp $file s3://[BUCKET]/images/`date +%Y-%m-%d`/jpg/
    mv $file `echo $file|sed 's/\.jpg/\.jpeg/'`
    done
}

if mkdir /tmp/lock/mylock; then
  if cd /usr/storage/images/`date +%Y-%m-%d`; then
     find . -type f -name \*.jpg -mmin +1 | myFunction
  fi
  rmdir /tmp/lock/mylock
else
  logger -p local0.notice "mylock found, skipping run"
fi

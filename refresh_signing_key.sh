#!/bin/sh

# Script to update signing key in the /etc/nginx/nginx.conf file weekly via a cronjob
# Uses generate_signing_key.py provided with AWS_AUTH nginx module
# Replace [AWS SECRET KEY] and [AWS-REGION] below

read var1 var2 <<< $(/path/to/generate_signing_key.py -k [AWS SECRET KEY] -r [AWS-REGION])

sed -i "s|\( *aws_signing_key *\).*|\1$var1; #Example L4vRLWAO92X5L3Sqk5QydUSdB0nC9+1wfqLMOKLbRp4=|" /etc/nginx/nginx.conf
sed -i "s|\( *aws_key_scope *\).*|\1$var2; #Example 20150830\/us-east-1\/service\/aws4_request|" /etc/nginx/nginx.conf

# Make nginx server re-read the config file
kill -HUP `cat /var/run/nginx.pid`

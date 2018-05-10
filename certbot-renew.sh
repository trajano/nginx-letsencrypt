#!/bin/sh
sleep $(( ${RANDOM} % 30 ))m
certbot renew -a webroot -w /tmp  --deploy-hook "nginx -s reload"

#!/bin/sh
sleep $(( ${RANDOM} % 30 ))m
(
flock -s 200

certbot renew -a webroot -w /tmp  --deploy-hook "nginx -s reload"
) 200>/etc/letsencrypt/lock

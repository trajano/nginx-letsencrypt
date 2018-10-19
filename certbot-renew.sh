#!/bin/sh
sleep $(( ${RANDOM} % 30 ))m
(
flock -s 300
certbot renew -a webroot -w /tmp  --deploy-hook "nginx -s reload"
) 300>/etc/letsencrypt/lock

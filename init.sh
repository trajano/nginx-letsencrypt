#!/bin/bash -e
if [[ -z "${EMAIL}" ]]
then
  echo "EMAIL needs to be set"
  exit 1
fi

if [[ -z "${DOMAINS}" ]]
then
  echo "DOMAINS needs to be set"
  exit 1
fi


(
flock -s 200

if [ ! -e /etc/letsencrypt/live ]
then

  openssl dhparam -out /etc/letsencrypt/dhparam.pem 4096 > /dev/null 2>&1 &
  certbot -n -q certonly --standalone --email ${EMAIL} --agree-tos --rsa-key-size 4096 --domains ${DOMAINS}
  wait

fi

) 200>/etc/letsencrypt/lock

DOMAIN=$(echo $DOMAINS | cut -d ',' -f 1) envsubst < /etc/nginx/conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf
crond &
exec nginx -g "daemon off;"

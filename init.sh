#!/bin/bash -e
if [[ -z "${EMAIL}" ]]
then
  echo "EMAIL needs to be set"
  exit 1
fi

if [[ -z "${SERVERS}" ]]
then
  echo "SERVERS needs to be set"
  exit 1
fi

DOMAIN=$(echo $SERVERS | awk '{ print $1 }')

(
flock -s 200

if [ ! -e /etc/letsencrypt/live ]
then

  echo "-n -q certonly --standalone --email ${EMAIL} --agree-tos --rsa-key-size 4096" $(echo $SERVERS | sed 's/[^ ]* */-d &/g') | xargs certbot
  openssl dhparam -out /etc/letsencrypt/dhparams.pem 4096 > /dev/null

fi

) 200>/etc/letsencrypt/lock

envsubst < /etc/nginx/conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf
crond &
exec nginx -g "daemon off;"

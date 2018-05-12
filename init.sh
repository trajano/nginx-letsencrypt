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

for server in $(echo $DOMAINS | sed s/,/ /g )
do
  DOMAIN=$(echo $DOMAINS | cut -d ',' -f 1) SERVER=${server} envsubst < /etc/nginx/conf.d/default.conf.tmpl > /etc/nginx/conf.d/${server}.conf
  if [ ! -e /etc/nginx/conf.d/${server}.conf.* ]
  then
    echo "return 502;" > /etc/nginx/conf.d/${server}.conf.default
  fi
done
NUMPROCS=$(cat /sys/fs/cgroup/cpuacct/cpuacct.usage_percpu | wc -w)
sed -i "s/worker_processes\\s\\+1;/worker_processes ${NUMPROCS};/" /etc/nginx/nginx.conf
crond
exec nginx -g "daemon off;"

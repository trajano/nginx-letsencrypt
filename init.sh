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

(
flock -s 200

# ... commands executed under lock ...

) 200>/var/lock/letsencrypt

ARGS="-n -q certonly -a wwwroot 
echo $SERVERS | sed 's/[^ ]* */-d &/g'

servers=()
for server in ${SERVERS}
do
    servers += ( '-d' )
    servers += ( "$server" )
done

for arg in "${new_args[@]}"
do
    echo "$arg"
done

if [ ! -e /etc/letsencrypt/live ]
then
  certbot -n -q certonly --standalone --email arch@trajano.net --agree-tos --rsa-key-size 4096 -d trajano.net -d www.trajano.net -d i.trajano.net -d gw.trajano.net -d site.trajano.net -d ms.trajano.net
  openssl dhparam -out /etc/letsencrypt/dhparams.pem 4096 > /dev/null
else
  certbot -q renew
fi
exec nginx -g "daemon off;"

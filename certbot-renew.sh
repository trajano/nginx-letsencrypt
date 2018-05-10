#!/bin/sh
certbot renew -a webroot -w /tmp  --deploy-hook "nginx -s reload"

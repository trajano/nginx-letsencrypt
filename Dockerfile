FROM nginx:1.13.12-alpine
LABEL maintainer="archie@trajano.net"
EXPOSE 443
VOLUME /etc/letsencrypt
RUN apk add py-urllib3 openssl certbot curl --no-cache --repository http://dl-3.alpinelinux.org/alpine/v3.7/community/ --repository http://dl-3.alpinelinux.org/alpine/v3.7/main/ \
  && rm -rf /var/cache/apk/*
COPY init.sh /init
COPY certbot-renew.sh /etc/periodic/daily
RUN chmod 700 /init /etc/periodic/daily/certbot-renew.sh
CMD [ "/init" ]
HEALTHCHECK --start-period=30s CMD curl --fail http://localhost/ping || exit 1

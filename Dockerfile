FROM nginx:1.14.0-alpine
LABEL maintainer="archie@trajano.net"
EXPOSE 443
VOLUME /etc/letsencrypt
RUN apk add py-urllib3 openssl certbot curl bash --no-cache --repository http://dl-3.alpinelinux.org/alpine/v3.7/community/ --repository http://dl-3.alpinelinux.org/alpine/v3.7/main/ \
  && rm -rf /var/cache/apk/*
COPY certbot-renew.sh /
COPY nginx-files/* /etc/nginx/
COPY init.sh /init
RUN echo "0 */12 * * * /certbot-renew.sh" >> /var/spool/cron/crontabs/root && \
     chmod 700 /init /certbot-renew.sh && \
     mkdir /etc/nginx/site.d /etc/nginx/deployment.d && \
     rm /etc/nginx/conf.d/default.conf
CMD [ "/init" ]
HEALTHCHECK --start-period=120s CMD curl --fail http://localhost/.well-known/ping || exit 1

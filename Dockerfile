FROM nginx:1.13.12-alpine
LABEL maintainer="archie@trajano.net"
EXPOSE 443
VOLUME /etc/letsencrypt
RUN apk add py-urllib3 openssl certbot curl bash --no-cache --repository http://dl-3.alpinelinux.org/alpine/v3.7/community/ --repository http://dl-3.alpinelinux.org/alpine/v3.7/main/ \
  && rm -rf /var/cache/apk/*
COPY init.sh /init
COPY certbot-renew.sh /etc/periodic/daily
COPY conf.d/* /etc/nginx/conf.d/
COPY nginx.conf /etc/nginx/nginx.conf
RUN chmod 644 /etc/nginx/conf.d/* && \
    chmod 700 /init /etc/periodic/daily/certbot-renew.sh && \
    mkdir /etc/nginx/stream.d && \
    rm /etc/nginx/conf.d/default.conf
CMD [ "/init" ]
HEALTHCHECK --start-period=30s CMD curl --fail http://localhost/.well-known/ping || exit 1

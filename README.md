# Nginx + LetsEncrypt on Docker

This container provides a nginx with LetsEncypt enabled.  When tested with SSLLabs it should yield and A+ rating.  It supports streaming along with the normal proxying support.

## How nginx is initially setup

1. `EMAIL` environment variable specifies the email address that will recieve the notifications when there is a renewal needed
2. `SERVERS` environment variable specifies a *comma* separated list of FQDNs for the certificate.  It is expected that the first one would be primary and will be put in the `/etc/letsencrypt/live` folder.  (Comma separated was choses to avoid the hassle of adding extra quotes)
3. When the `/etc/letsencrypt/live folder` is missing the `init` script will start up `certbot` in standalone mode.  This will create the necessary files to enable SSL.  Otherwise we would require two configuration files for nginx (one with and one without SSL).

# Customization points

`/etc/nginx/conf.d/{server_name}.conf.*` is expected to contain the virtual server specific configurations.  The default configuration will simply `return 502` (gateway eror) for every request.  The `/etc/nginx/conf.d` folder can be mounted as a volume if desired.

`/etc/nginx/stream.d` is expected to contain stream specific configurations which are useful for passing the request / response as is to an upstream server.  The `/etc/nginx/stream.d` folder can be mounted as a volume if desired.

The following is an example of an upstream server called `intranet` which the nginx server will route to if the request is for `i.trajano.net` the `default default_https` is needed to make it do the normal processing specified in the previous paragraph.

    upstream intranet {
        server intranet:443;
    }

    map $ssl_preread_server_name $upstream {
        default default_https;
        i.trajano.net intranet;
    }

## NOTE

* On first initialization there will be no output for a while, this is because the DHPARAM generation takes quite a bit of time combined with the initial certificate generation.
* The `worker_processes` value is adjusted automatically to the number of available CPUs from *cgroup*, nginx official image hard codes it to `1`.
* Due to the nature of nginx and SSL certificates, it is not safe to run this configuration with multiple replicas especially when there are renewals.  The `worker_processes` value is adjusted automatically to the number of available CPUs allocated though so it can handle more load.
* `/.well-known/acme-challenge` URI will points to `/tmp/.well-known/acme-challenge` to provides the challenges required by LetsEncrypt for renewals.

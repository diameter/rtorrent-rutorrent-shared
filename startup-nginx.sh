#!/usr/bin/env sh

set -x

chown -R nginx:nginx /var/www/rutorrent
cp /downloads/.htpasswd /var/www/rutorrent/
mkdir -p /downloads/.rutorrent/torrents
chown -R nginx:nginx /downloads/.rutorrent
mkdir -p /downloads/.log/nginx
chown nginx:nginx /downloads/.log/nginx

rm -f /etc/nginx/sites-enabled/*

rm -rf /etc/nginx/ssl

rm /var/www/rutorrent/.htpasswd


# Basic auth enabled by default
site=rutorrent-basic.nginx

# Check if TLS needed
if [ -e /downloads/nginx.key ] && [ -e /downloads/nginx.crt ]; then
    mkdir -p /etc/nginx/ssl
    cp /downloads/nginx.crt /etc/nginx/ssl/
    cp /downloads/nginx.key /etc/nginx/ssl/
    site=rutorrent-tls.nginx
fi

cp /root/$site /etc/nginx/sites-enabled/
[ -n "$NOIPV6" ] && sed -i 's/listen \[::\]:/#/g' /etc/nginx/sites-enabled/$site
[ -n "$WEBROOT" ] && ln -s /var/www/rutorrent /var/www/rutorrent/$WEBROOT

# Check if .htpasswd presents
if [ -e /downloads/.htpasswd ]; then
    cp /downloads/.htpasswd /var/www/rutorrent/ && chmod 755 /var/www/rutorrent/.htpasswd && chown nginx:nginx /var/www/rutorrent/.htpasswd
else
# disable basic auth
    sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/$site
fi

mkdir -p /run/nginx
nginx -g "daemon off;"


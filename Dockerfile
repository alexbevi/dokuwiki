FROM alpine:3.3
MAINTAINER Andrey Arapov <andrey.arapov@nixaid.com>

# Install the dependencies
RUN apk update && \
    apk add wget tar nginx php-fpm \
            ca-certificates php-xml php-gd php-openssl php-zlib php-zip

# Create the application user so that PHP-FPM can run
ENV USER dokuwiki
ENV UID 7300
ENV HOME /home/$USER
ENV DATA /opt/dokuwiki
RUN adduser -D -u $UID -h $HOME -s /bin/true $USER && \
    mkdir -p $DATA && \
    touch /var/log/php-fpm.log && \
    chown -Rh $USER:$USER $DATA /var/log/php-fpm.log

# Prepare the environment so that nginx can run as non-root
RUN mkdir -p /var/log/dokuwiki /var/lib/nginx/tmp && \
    ( cd /var/lib/nginx/tmp && \
      for i in client_body proxy fastcgi uwsgi scgi; do mkdir $i; done ) && \
    ( cd /var/log/nginx && \
      touch error.log access.log ) && \
    touch /var/run/nginx.pid && \
    chown -Rh nginx:nginx /var/log/nginx /var/lib/nginx /var/run/nginx.pid /var/log/dokuwiki

# Obtain the latest version of the DokuWiki and extract it
USER $USER
WORKDIR $DATA
RUN wget -qO- http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz \
    | tar xpz --strip-components=1 -C $DATA && \
    rm -f $DATA/install.php

# Copy the nginx configs and then launch the PHP-FPM and Nginx
USER root
COPY dokuwiki.conf /etc/nginx/conf.d/dokuwiki.conf
COPY nginx.conf /etc/nginx/nginx.conf
# Preseed DokuWiki with the default configuration
# Default user: admin, password: 12345
COPY [ "users.auth.php", "acl.auth.php", "local.php", "plugins.local.php", "$DATA/conf/" ]
RUN chown -Rh $USER:$USER $DATA/conf

CMD /bin/sh -c "find /var/lib/nginx/tmp > /dev/null; \
                su -s /bin/sh $USER -c php-fpm && \
                su -s /bin/sh nginx -c nginx"

VOLUME [ "$DATA/conf", "$DATA/data", "/var/log/dokuwiki" ]
EXPOSE 80/tcp

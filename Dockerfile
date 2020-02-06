# Based on: https://github.com/TrafeX/docker-php-nginx and https://github.com/leafney/alpine-mariadb

FROM alpine:3.10

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-mbstring php7-gd nginx supervisor curl \
    mariadb mariadb-client && \
    printf '[mysqld]\nskip-host-cache\nskip-name-resolve\nbind-address=0.0.0.0\n' > /etc/my.cnf.d/docker.cnf

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
# Remove default server definition
RUN rm /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini

COPY ./startup.sh /opt/bin/startup.sh
RUN chmod +x /opt/bin/startup.sh

COPY --chown=nobody config/mysql.sql /var/tmp/mysql.sql

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN mkdir -p /run/mysqld && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  chown -R nobody.nobody /var/lib/mysql

# Setup document root
RUN mkdir -p /www

# Make the document root a volume
VOLUME /www
VOLUME /var/lib/mysql

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /www
# COPY --chown=nobody src/ /www

# Expose the port nginx is reachable on
EXPOSE 8080

# MySQL port
EXPOSE 3306

# Let supervisord start nginx & php-fpm
CMD ["/opt/bin/startup.sh"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
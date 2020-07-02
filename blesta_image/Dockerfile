FROM alpine:3.12

LABEL Maintainer="Eddy <me@edy.io>" \
      Description="Blesta with Nginx & PHP-FPM based on Alpine Linux"

ENV BLESTA_VERSION=4.10.2 \
    DOWNLOAD_ID=154

ARG GID=1000
ARG UID=1000

# Install packages and remove default server definition
RUN apk --no-cache add php7 php7-fpm php7-opcache php7-mysqli php7-json php7-openssl php7-curl php7-gmp \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session php7-imap \
    php7-pdo_mysql php7-pdo php7-mbstring php7-gd php7-iconv php7-simplexml php7-pecl-mailparse nginx supervisor curl shadow && \
    rm /etc/nginx/conf.d/default.conf

# Download ioncube
RUN cd /tmp \
    && curl -sSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube.tar.gz \
    && tar -xf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.3.so /usr/lib/php7/modules/ioncube_loader_lin_7.3.so \
    && echo 'zend_extension = /usr/lib/php7/modules/ioncube_loader_lin_7.3.so' > /etc/php7/conf.d/00-ioncube.ini \
    && rm ioncube.tar.gz

# Copy configs
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create root directory
RUN mkdir -p /var/www/html
COPY config/entrypoint.sh /var/www/entrypoint.sh
RUN chmod +x /var/www/entrypoint.sh

# Add Blesta's cron
RUN echo '*/5 * * * * nobody /usr/local/bin/php /var/www/app/blesta/index.php cron' > /etc/crontabs/blesta

# Change UID and GID of nobody to 1000 to match most host user's IDs
RUN usermod -u ${UID} nobody && groupmod -g ${GID} nobody

# Run as non-root user
RUN chown -R nobody.nobody /var/www \
    && chown -R nobody.nobody /run \
    && chown -R nobody.nobody /var/lib/nginx \
    && chown -R nobody.nobody /var/log/nginx

# Switch to non-root user
USER nobody

# Change working directory
WORKDIR /var/www

# Download blesta
RUN curl -Lo blesta.zip https://account.blesta.com/client/plugin/download_manager/client_main/download/${DOWNLOAD_ID} \
    && unzip blesta.zip \
    && rm blesta.zip

# Expose the port nginx is reachable on
EXPOSE 8080

# Execute scripts on start
ENTRYPOINT ["/var/www/entrypoint.sh"]

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Healthcheck
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping


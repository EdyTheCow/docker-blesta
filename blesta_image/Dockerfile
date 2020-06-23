FROM php:7.2-apache

ENV BLESTA_VERSION=4.10.1 \
    DOWNLOAD_ID=152 \
    MAXMIND_KEY=key

ENV BUILD_DEPS \
        cron \
        g++ \
        gettext \
        libicu-dev \
        openssl \
        libc-client-dev \
        libkrb5-dev \
        libxml2-dev \
        libfreetype6-dev \
        libgd-dev \
        libmcrypt-dev \
        bzip2 \
        libbz2-dev \
        libtidy-dev \
        libcurl4-openssl-dev \
        libz-dev \
        libmemcached-dev \
        libxslt-dev \
        libgmp-dev \
        libldap2-dev \
        python3 \
        python3-pycurl \
        unzip \
        wget \
        supervisor \
        git

RUN apt-get update \
    && apt-get install --yes --no-install-recommends $BUILD_DEPS \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install pdo pdo_mysql curl gmp imap json ldap mbstring simplexml gd \
    && yes '' | pecl install -f mailparse mcrypt-1.0.1 \
    && docker-php-ext-enable mcrypt \
    && a2enmod rewrite \
    && a2enmod headers \
    && a2enmod remoteip  \
    && apt-get -y autoclean && apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /etc/cron.{hourly,daily,weekly,monthly} \
    && echo "extension=mailparse.so" > /usr/local/etc/php/conf.d/docker-php-ext-mailparse.ini \
    && sed -i 's/^LogFormat/#&/' /etc/apache2/apache2.conf \
    && echo "[PHP]" >> /usr/local/etc/php/php.ini \
    && echo "expose_php=Off" >> /usr/local/etc/php/php.ini \
    && echo "ServerTokens Prod" >> /etc/apache2/conf-enabled/security.conf \
    && echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf \
    && ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
    && ln -sf /proc/self/fd/1 /var/log/apache2/error.log \
    && curl -sSL -o /tmp/ioncube.zip http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip \
    && unzip /tmp/ioncube.zip -d /usr/local/lib/php/extensions/* \
    && rm -Rf /tmp/ioncube.zip \
    && echo "zend_extension=ioncube/ioncube_loader_lin_7.2.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube.ini

COPY ./supervisord.conf /etc/supervisor/supervisord.conf
COPY ./logformat.conf /etc/apache2/conf-enabled/logformat.conf
COPY ./remoteip.conf /etc/apache2/conf-enabled/remoteip.conf
COPY ./entrypoint.sh /entrypoint.sh

RUN mkdir /var/www/app \
    && curl -o blesta.zip -sSL https://account.blesta.com/client/plugin/download_manager/client_main/download/${DOWNLOAD_ID}/blesta-${BLESTA_VERSION}.zip \
    && unzip blesta.zip -d /var/www/app \
    && rm blesta.zip \
    && chown -R www-data:www-data /var/www/app/blesta/cache /var/www/app/uploads /var/www/app/blesta/config \
    && mv /var/www/app /var/www/docker-backup-app \
    && sed -ri -e 's!/var/www/html!/var/www/app/blesta!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/html!/var/www/app/blesta!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && echo '*/5 * * * * www-data /usr/local/bin/php /var/www/app/blesta/index.php cron' > /etc/cron.d/blesta

VOLUME /var/www/app
WORKDIR /var/www/app
EXPOSE 80

HEALTHCHECK CMD curl --silent --fail localhost:80 || exit 1
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]


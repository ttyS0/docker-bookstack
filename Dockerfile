FROM php:7.4.2-apache-buster AS base

ENV BOOKSTACK=BookStack \
    BOOKSTACK_VERSION=0.28.2 \
    BOOKSTACK_HOME="/var/www/bookstack"

RUN apt-get -yqq update && \
    apt-get install -yq --no-install-recommends fonts-freefont-ttf curl wget libtidy5deb1 libpng-tools libmcrypt4 libjpeg62-turbo libfreetype6 libzip4 && \
    apt-get autoremove -y && \
    apt-get clean -y

FROM base AS build

RUN apt-get -yqq update && \
    apt-get install -y --no-install-recommends git zlib1g-dev libzip-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libtidy-dev libxml2-dev fontconfig tar  \
   && docker-php-ext-install dom pdo pdo_mysql zip tidy gd \
   && cd /var/www && curl -sS https://getcomposer.org/installer | php \
   && mv /var/www/composer.phar /usr/local/bin/composer \
   && wget https://github.com/BookStackApp/BookStack/archive/v${BOOKSTACK_VERSION}.tar.gz -O ${BOOKSTACK}.tar.gz \
   && tar -xf ${BOOKSTACK}.tar.gz && mv BookStack-${BOOKSTACK_VERSION} ${BOOKSTACK_HOME} && rm ${BOOKSTACK}.tar.gz  \
   && cd $BOOKSTACK_HOME && composer install \
   && chown -R www-data:www-data $BOOKSTACK_HOME \
   && apt-get -y autoremove \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/* /var/tmp/* /etc/apache2/sites-enabled/000-*.conf /usr/src

FROM base AS release

COPY --from=build /usr/local /usr/local/
COPY --from=build /var/www /var/www/

COPY php.ini /usr/local/etc/php/php.ini
COPY bookstack.conf /etc/apache2/sites-enabled/bookstack.conf

RUN a2enmod rewrite && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /etc/apache2/sites-enabled/000-*.conf /usr/src

COPY docker-entrypoint.sh /

WORKDIR $BOOKSTACK_HOME

EXPOSE 80

VOLUME ["$BOOKSTACK_HOME/public/uploads","$BOOKSTACK_HOME/storage/uploads"]

ENTRYPOINT ["/docker-entrypoint.sh"]


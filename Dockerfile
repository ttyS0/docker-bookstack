FROM php:7.4.5-apache-buster AS base

ENV BOOKSTACK=BookStack \
    BOOKSTACK_VERSION=0.29.3 \
    BOOKSTACK_HOME="/var/www/bookstack"

RUN apt-get -yqq update \
    && apt-get install -yq --no-install-recommends \
        fonts-freefont-ttf \
        curl \
        libtidy5deb1 \
        libpng-tools \
        libmcrypt4 \
        libjpeg62-turbo \
        libfreetype6 \
        libzip4 \
        fonts-freefont-ttf \
        wkhtmltopdf \
    && apt-get autoremove -y \
    && apt-get clean -y

FROM base AS build

RUN apt-get -yqq update \
    && apt-get install -y --no-install-recommends \
        git \
        zlib1g-dev \
        libzip-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libtidy-dev \
        libxml2-dev \
        fontconfig \
        tar \
        unzip \
   && docker-php-ext-install dom pdo pdo_mysql zip tidy gd \
   && curl -SL -o ${BOOKSTACK}.tar.gz https://github.com/BookStackApp/BookStack/archive/v${BOOKSTACK_VERSION}.tar.gz \
   && mkdir -p ${BOOKSTACK_HOME} \
   && tar xvf ${BOOKSTACK}.tar.gz -C ${BOOKSTACK_HOME} --strip-components=1 \
   && cd ${BOOKSTACK_HOME} \
   && curl -sS https://getcomposer.org/installer | php \
   && ${BOOKSTACK_HOME}/composer.phar install -v -d ${BOOKSTACK_HOME} \
   && rm -rf ${BOOKSTACK_HOME}/composer.phar /root/.composer \
   && chown -R www-data:www-data ${BOOKSTACK_HOME}

FROM base AS release

COPY --from=build /usr/local /usr/local/
COPY --from=build --chown=33:33 /var/www /var/www/

COPY php.ini /usr/local/etc/php/php.ini
COPY bookstack.conf /etc/apache2/sites-enabled/bookstack.conf
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh

RUN a2enmod rewrite \
   && rm -rf /var/lib/apt/lists/* /var/tmp/* /etc/apache2/sites-enabled/000-*.conf /usr/src

WORKDIR ${BOOKSTACK_HOME}

EXPOSE 80

VOLUME ["$BOOKSTACK_HOME/public/uploads","$BOOKSTACK_HOME/storage/uploads"]

ENTRYPOINT ["/bin/docker-entrypoint.sh"]


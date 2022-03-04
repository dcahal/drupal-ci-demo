# Composer builder
ARG DRUPAL_ROOT
ARG THEME_DIR
FROM docker.io/php:8.1-cli as composer

COPY composer.sh /app/

ENV PATH="$PATH:$HOME/.composer/vendor/bin"
ENV NVM_DIR="$PLATFORM_APP_DIR/.nvm"

RUN apt-get update && apt-get install --no-install-recommends --assume-yes \
    git \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libpq-dev \
    libzip-dev \
    webp \
    libwebp-dev \
    unzip

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

RUN docker-php-ext-install -j "$(nproc)" \
    gd \
    opcache \
    pdo_mysql \
    zip

WORKDIR /app/

RUN bash -x ./composer.sh

RUN php composer.phar --version

RUN php composer.phar install

RUN rm -f composer.phar 

# Node builder for theme
FROM docker.io/node:16.13.2-buster as node
ARG DRUPAL_ROOT
ARG THEME_DIR
COPY --from=composer /app/ /usr/src/

RUN apt-get update && apt-get install php-cli -no-install-recommends --assume-yes
RUN curl -f -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
RUN [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
RUN npm install && \
    npm install -g gulp-cli
WORKDIR /web/themes/custom/sba
RUN gulp build-sass
RUN rm -rf ./node_modules

# Drupal 9 final container 
FROM docker.io/php:8.1-apache
ARG DRUPAL_ROOT
ENV APACHE_DOCUMENT_ROOT /var/www/html/${DRUPAL_ROOT}
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install runtime dependencies
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && \
    apt-get install -y --no-install-recommends \
    default-mysql-client \
    libfcgi-bin \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libpq-dev \
    libzip-dev \
    webp \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

RUN docker-php-ext-install -j "$(nproc)" \
    gd \
    opcache \
    pdo_mysql \
    zip

COPY --from=node /usr/src/ /var/www/html/
COPY ./drush /usr/local/bin/drush
RUN chmod a+x /usr/local/bin/drush

RUN chown --recursive www-data. /var/www/html/

# Enable mod_expires
RUN ln -s /etc/apache2/mods-available/expires.load /etc/apache2/mods-enabled/expires.load

# Enable mod_headers
RUN ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load

# Enable mod_rewrite
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

RUN rm -f /etc/apache2/sites-enabeled/000-default.conf

COPY ./apache_entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

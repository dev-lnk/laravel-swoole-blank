FROM php:8.4-cli AS php

WORKDIR /var/www/app

ARG gid
ARG uid

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libc6 \
    zip \
    unzip \
    supervisor \
    htop \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    postgresql-client \
    libcurl4-openssl-dev \
    libc-ares-dev \
    libpq-dev \
    libssl-dev \
    ca-certificates \
    gnupg \
    libicu-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-jpeg --with-freetype
RUN docker-php-ext-configure intl
RUN docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath gd zip sockets intl

RUN pecl install redis \
    && docker-php-ext-enable redis

# Install Swoole
RUN pecl install swoole \
    && docker-php-ext-enable swoole

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install chokidar globally
RUN npm install -g chokidar-cli

COPY --from=composer:2.8.5 /usr/bin/composer /usr/bin/composer

RUN groupadd -g ${gid} app-user && useradd -u ${uid} -g app-user -m -s /bin/bash app-user
RUN mkdir -p /var/www/app && chown -R app-user:app-user /var/www/app

FROM php AS dev

ARG xdebug_idekey
ARG xdebug_client_port

COPY ./docker/config/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN pecl install xdebug-3.4.5 && \
      docker-php-ext-enable xdebug && \
      sed -i "s/^xdebug\.idekey=.*/xdebug.idekey=${xdebug_idekey}/" /usr/local/etc/php/conf.d/xdebug.ini && \
      sed -i "s/^xdebug\.client_port=.*/xdebug.client_port=${xdebug_client_port}/" /usr/local/etc/php/conf.d/xdebug.ini

COPY . .

COPY ./docker/config/php/entrypoint-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod -R 775 ./storage ./bootstrap/cache
RUN mkdir -p /tmp/cache && chown -R app-user:app-user /tmp/cache

USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

FROM php AS build

COPY composer.json composer.lock ./

RUN composer install --no-dev --no-scripts --prefer-dist --no-progress --no-interaction

COPY . .

RUN composer dump-autoload --optimize && \
    composer check-platform-reqs

RUN chmod -R 775 ./storage ./bootstrap/cache

FROM build AS prod
COPY ./docker/config/php/entrypoint-prod.sh /usr/local/bin/entrypoint.sh
COPY ./docker/config/php/supervisord-octane-prod.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN rm -rf /docker
USER root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

FROM build AS worker
RUN rm -rf /docker
CMD ["/bin/sh", "-c", "supervisord -c /etc/supervisor/supervisord.conf"]

FROM build AS scheduler
RUN rm -rf /docker
USER app-user
CMD ["/bin/sh", "-c", "nice -n 10 sleep 60 && php /var/www/app/artisan schedule:run --verbose --no-interaction"]
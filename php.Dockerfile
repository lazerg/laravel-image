ARG PHP_VERSION=null

FROM php:${PHP_VERSION}-fpm

ARG NODE_VERSION=null
ARG WITH_XDEBUG=null

# Install dependencies
RUN apt-get update
RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libjpeg62-turbo-dev
RUN apt-get install -y libmcrypt-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libzip-dev
RUN apt-get install -y libonig-dev
RUN apt-get install -y graphviz
RUN apt-get install -y libicu-dev
RUN apt-get install -y ghostscript
RUN apt-get install -y supervisor
RUN apt-get install -y dos2unix
RUN apt-get install -y mc
RUN apt-get install -y htop
RUN apt-get install -y nano
RUN apt-get install -y wget
RUN apt-get install -y nginx
RUN apt-get install -y git
RUN apt-get install -y sqlite3

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# GD extension
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install gd

# Swoole extension
RUN pecl install swoole
RUN docker-php-ext-enable swoole

# Redis extension
RUN pecl install -o -f redis
RUN rm -rf /tmp/pear
RUN docker-php-ext-enable redis

RUN if [ "$WITH_XDEBUG" = "true" ]; then \
        # xDebug
        pecl install xdebug && \
        docker-php-ext-enable xdebug && \
        # xDebug configuration
        echo "zend_extension=xdebug.so" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
        echo "xdebug.mode=develop,debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
        echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
        echo "xdebug.discover_client_host=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
        echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    fi

# Other PHP extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip
RUN docker-php-ext-install intl
RUN docker-php-ext-install exif
RUN docker-php-ext-install sockets
RUN docker-php-ext-install pcntl
RUN docker-php-source delete

# PostgreSQL
RUN apt-get install -y libpq-dev
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pdo_pgsql pgsql

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn

# Aliases
RUN echo "alias 'p=php artisan test'" >> ~/.bashrc
RUN echo "alias 'pf=php artisan test --filter='" >> ~/.bashrc

WORKDIR /var/www/app/

EXPOSE 9000

CMD ["php-fpm"]

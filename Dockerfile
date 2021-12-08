FROM php:8.0.13-fpm

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
        graphviz \
        ghostscript \
        dos2unix mc htop nano wget nginx \

    # Nodejs
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \

    # GD
    && docker-php-ext-configure gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
        --with-freetype=/usr/include/ \
    && docker-php-ext-install gd \

    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install zip \
    && docker-php-ext-install sockets \
    && docker-php-source delete \
    
    # Postgresql
    && apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql \

    # Composer
    && curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin --filename=composer \
        
    # Aliases
    && echo "\
    alias 'p=/var/www/app/vendor/bin/phpunit' \n\
    alias 'pf=/var/www/app/vendor/bin/phpunit --filter' \n\
    " >> ~/.bashrc

WORKDIR /var/www/app/

EXPOSE 9000

CMD ["php-fpm"]

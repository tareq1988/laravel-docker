FROM php:7.3-fpm-alpine

# Install PHP extensions and PECL modules.
RUN apk add bzip2-dev php7-dev zip unzip icu-dev libxml2-dev libzip-dev freetype-dev libjpeg-turbo-dev libpng-dev \
    && docker-php-ext-install bcmath bz2 calendar iconv intl mbstring mysqli opcache pdo_mysql soap zip  \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install exif \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached.so redis.so

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer
ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1

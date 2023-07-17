FROM php:8.2.8-apache

CMD /bin/bash

RUN a2enmod rewrite

RUN apt-get -qq update && apt-get -qq -y install python3 curl zlib1g-dev g++ libicu-dev libargon2-1 libzip-dev libmagickwand-dev unzip libpng-dev libjpeg-dev libonig-dev libfreetype6-dev \
        && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg=/usr 

RUN docker-php-ext-install bcmath exif gd mysqli zip intl opcache \
        ; \
        pecl install imagick-3.7.0; \
        docker-php-ext-enable imagick

VOLUME /var/www/html

ENV WORDPRESS_VERSION 6.3-beta4
ENV WORDPRESS_UPSTREAM_VERSION 6.3-beta4
ENV WORDPRESS_SHA1 6995c76ab278839e52938e9e620475e12d8d3158

ADD /plugins /

RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_UPSTREAM_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
        && unzip -q /wp-super-cache.1.9.4.zip -d /usr/src/wordpress/wp-content/plugins/ \
        && unzip -q /jetpack-boost.1.9.4.zip  -d /usr/src/wordpress/wp-content/plugins/ \
	&& rm wordpress.tar.gz && rm /*.zip \
	&& chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]

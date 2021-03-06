FROM php:8.0-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y unzip libpng-dev libjpeg-dev libonig-dev libfreetype6-dev \
        && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg=/usr \
	&& docker-php-ext-install gd
RUN docker-php-ext-install mysqli

VOLUME /var/www/html

ENV WORDPRESS_VERSION 5.8
ENV WORDPRESS_UPSTREAM_VERSION 5.8
ENV WORDPRESS_SHA1 6476e69305ba557694424b04b9dea7352d988110

ADD /plugins /
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_UPSTREAM_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
        && unzip -q /redis-cache.2.0.21.zip -d /usr/src/wordpress/wp-content/plugins/ \
        && unzip -q /elementor.3.4.3.zip -d /usr/src/wordpress/wp-content/plugins/ \
        && unzip -q /elementor-pro-3.4.1.zip -d /usr/src/wordpress/wp-content/plugins/ \
	&& rm wordpress.tar.gz && rm /*.zip \
	&& chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]

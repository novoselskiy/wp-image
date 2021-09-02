FROM arm64v8/wordpress

COPY redis-cache/ /var/www/html/wp-content/plugins/redis-cache/

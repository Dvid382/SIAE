FROM composer:2.7 as build
WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader

FROM php:8.2-fpm-alpine
WORKDIR /app
COPY --from=build /app /app

# Instalar dependencias para PostgreSQL
RUN apk add --no-cache postgresql-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Permisos y optimización
RUN chmod -R 775 storage bootstrap/cache && \
    php artisan config:clear && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

EXPOSE 10000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]

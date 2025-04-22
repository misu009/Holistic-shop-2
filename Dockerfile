# Base image with PHP, Composer, and Node 18+
FROM laravelsail/php83-composer AS build

# Install system dependencies and Node.js 18
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip libzip-dev gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy only the essentials first (to cache dependencies)
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Build frontend assets
RUN npm run build

# Install Laravel Sail
RUN curl -s https://laravel.com/installer | php

# Set permissions (only necessary dirs)
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose port 8000 if using Laravel's built-in server
EXPOSE 8000

# Run migrations and seed database using Sail (ensure Laravel Sail is installed)
CMD ./vendor/bin/sail up -d && ./vendor/bin/sail artisan migrate:fresh --seed --force && ./vendor/bin/sail artisan serve --host=0.0.0.0 --port=8000

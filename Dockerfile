# Base image with PHP, Composer and Node 18+
FROM laravelsail/php83-composer AS build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip libzip-dev \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Set working directory
WORKDIR /var/www/html

# Copy existing application
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install Node modules and build assets
RUN npm install && npm run build

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Run migrations and seed DB when the container starts
CMD php artisan migrate:fresh --seed --force && php-fpm

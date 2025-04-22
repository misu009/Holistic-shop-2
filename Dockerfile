# Base image with PHP, Composer, and Node 18+
FROM laravelsail/php83-composer AS build

# Install system dependencies and Node.js 18
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip libzip-dev libjpeg-dev libfreetype6-dev \
    php-pdo php-pdo-mysql php-mbstring php-xml php-zip \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update

# Set working directory
WORKDIR /var/www/html

# Copy composer.json and composer.lock to optimize caching
COPY composer.json composer.lock ./

# Run composer diagnose
RUN composer diagnose

# Install PHP dependencies with verbose logging
RUN composer install --no-dev --optimize-autoloader -vvv

# Install npm dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Build frontend assets
RUN npm run build

# Set permissions for Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose port 8000 for Laravel server
EXPOSE 8000

# Run migrations and seed database using Sail
CMD ./vendor/bin/sail up -d && ./vendor/bin/sail artisan migrate:fresh --seed --force && ./vendor/bin/sail artisan serve --host=0.0.0.0 --port=8000

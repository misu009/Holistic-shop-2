# Base image with PHP, Composer, and Node 18+
FROM laravelsail/php83-composer AS build

# Install system dependencies
RUN apt-get update -y && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip libzip-dev libjpeg-dev libfreetype6-dev

# Install Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && composer self-update

# Set working directory
WORKDIR /var/www/html

# Copy composer.json and composer.lock for optimized caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader -vvv

# Install Node dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Build frontend assets
RUN npm run build

# Set permissions for Laravel storage and cache directories
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose port 8000 for the Laravel server
EXPOSE 8000

# Run migrations, seed database, and serve the app
CMD ./vendor/bin/sail up -d && ./vendor/bin/sail artisan migrate:fresh --seed --force && ./vendor/bin/sail artisan serve --host=0.0.0.0 --port=8000

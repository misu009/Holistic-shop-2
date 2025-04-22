# Use the Laravel Sail PHP 8.3 Composer base image
FROM laravelsail/php83-composer AS build

# Install system dependencies
RUN apt-get update -y && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip libzip-dev \
    libjpeg-dev libfreetype6-dev \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update

# Set working directory inside the container
WORKDIR /var/www/html

# Copy existing application to the container
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader -vvv

# Install Node dependencies
RUN npm install

# Build the assets
RUN npm run build

# Set the correct permissions for Laravel application directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Default command to run when the container starts
# Will run the migration and seed the database
CMD ["./vendor/bin/sail", "artisan", "migrate:fresh", "--seed", "--force", "&&", "./vendor/bin/sail", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

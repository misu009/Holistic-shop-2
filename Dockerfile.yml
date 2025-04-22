# Use an official PHP image with necessary extensions
FROM php:8.1-fpm

# Set working directory in the container
WORKDIR /var/www

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev zip git curl unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js and npm (for assets)
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Copy the existing application directory contents to the container
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Install front-end dependencies
RUN npm install && npm run production

# Set permissions for storage and cache
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Expose the port the app runs on
EXPOSE 9000

# Command to run the Laravel app
CMD ["php-fpm"]

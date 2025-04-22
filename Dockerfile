# Use official PHP image with Apache
FROM php:8.3-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl zip libzip-dev libpng-dev libonig-dev libxml2-dev \
    libpq-dev libcurl4-openssl-dev pkg-config libssl-dev \
    && docker-php-ext-install pdo pdo_pgsql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js (v20) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Set working directory
WORKDIR /var/www/html

# Copy all application files
COPY . .

# Configure Apache to serve from Laravel's public directory
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install PHP dependencies (include dev for Faker)
RUN composer install --optimize-autoloader

# Build front-end assets
RUN npm ci && npm run build

# Set permissions only for writable directories
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 755 storage bootstrap/cache

# Copy the entrypoint script
COPY render-start.sh /usr/local/bin/render-start.sh
RUN chmod +x /usr/local/bin/render-start.sh

# Expose port 80
EXPOSE 80

# Run the entrypoint
CMD ["/usr/local/bin/render-start.sh"]

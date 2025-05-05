FROM php:8.3-apache

# Install system packages and Node.js
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    zip \
    git \
    unzip \
    curl \
    libpq-dev \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module
RUN a2enmod rewrite && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Set Laravel public folder as Apache root
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Set working directory
WORKDIR /var/www/html

# Copy Laravel app files
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Install JS dependencies and compile assets
RUN npm install && npm run build

# Copy startup script into container
COPY render-start.sh /usr/local/bin/render-start.sh
RUN chmod +x /usr/local/bin/render-start.sh

# Expose Render's required port
EXPOSE 8080

# Run startup script when container launches
CMD ["/usr/local/bin/render-start.sh"]
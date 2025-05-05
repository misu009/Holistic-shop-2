#!/bin/bash

# Ensure required directories and files exist
mkdir -p storage/logs bootstrap/cache
touch storage/logs/laravel.log

# Set correct permissions for Laravel storage and cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Clear and regenerate Laravel caches
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run database migrations and seed
php artisan migrate:refresh --seed --force

# Start Apache in the foreground
exec apache2-foreground
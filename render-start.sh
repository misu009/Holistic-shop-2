#!/bin/bash

# Ensure Laravel config is cached
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations and seeders
php artisan migrate --force
php artisan db:seed --force

# Start Apache in the foreground
apache2-foreground

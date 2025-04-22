#!/bin/bash

# Run Laravel migrations and seeders
php artisan migrate --force
php artisan db:seed --force

# Start Apache in foreground
apache2-foreground

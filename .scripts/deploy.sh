#!/bin/bash
set -e  # Stop script on errors

echo "Deployment started..."

# Check if Laravel is already in maintenance mode before enabling it
if ! php artisan up; then 
    php artisan down
fi

echo "Pulling latest changes..."
git reset --hard
git pull origin master || { echo "Git pull failed"; exit 1; }

echo "Installing dependencies..."
composer install --no-interaction --no-dev --optimize-autoloader || { echo "Composer install failed"; exit 1; }

echo "Running database migrations..."
php artisan migrate --force || { echo "Migrations failed"; exit 1; }

echo "Restarting queue and clearing cache..."
php artisan queue:restart || true
php artisan config:clear
php artisan cache:clear
php artisan view:clear

echo "Restarting PHP-FPM..."
sudo systemctl restart php-fpm || true

echo "Bringing the app back up..."
php artisan up  # Ensure app is live after deployment

echo "Deployment completed successfully!"

#! /bin/bash

echo "Deployment Started......"

echo "This app is being updated. Please try again in a minute"

(php artisan down) || true

git fetch origin master
git reset --hard origin/master
git pull origin master


npm install && npm run build

COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

php artisan clear-compiled
php artisan route:clear
php artisan cache:clear
php artisan config:clear
php artisan view:clear


php artisan config:cache
php artisan optimize

php artisan migrate --force

php artisan up

echo "deployment completed...."

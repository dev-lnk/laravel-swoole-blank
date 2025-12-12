#!/bin/sh
set -e

# Create necessary directories
mkdir -p /var/www/app/storage/logs
mkdir -p /run

# Set proper permissions
chown -R app-user:app-user /var/www/app/storage /var/www/app/bootstrap/cache

# Wait for database to be ready
echo "Waiting for database connection..."
until php artisan db:show 2>/dev/null; do
    echo "Database is unavailable - sleeping"
    sleep 2
done

echo "Database is up - running migrations and optimizations"

php artisan migrate --force
php artisan optimize:clear
php artisan optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start supervisor to run Octane
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
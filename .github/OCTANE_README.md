# Laravel Octane + Swoole in Docker

This project is configured to run Laravel Octane and Swoole in Docker containers.

## Architecture

- **PHP container**: Runs Octane through Supervisor on port 8000
- **Nginx container**: Proxies requests to Octane
- **Swoole**: High-performance application server
- **Supervisor**: Manages the Octane process
- **Chokidar**: Installed for file watching in dev mode

## Configuration

### Main files

1. **docker/dockerfiles/php/Dockerfile**
   - Installs the Swoole extension
   - Installs Node.js and npm
   - Installs chokidar-cli globally
   - Installs the socket extension for Swoole

2. **docker/config/php/supervisord-octane.conf**
   - Supervisor configuration for running Octane

3. **docker/config/nginx/nginx.conf**
   - Proxying to Octane (php:8000)

4. **config/octane.php**
   - Configured to use Swoole
   - Swoole options configuration

## Monitoring

### Checking Swoole

```bash
# Check Swoole processes
docker-compose exec php ps aux | grep swoole

# View supervisor logs
docker-compose exec php supervisorctl tail -f octane

# Check Swoole statistics
docker-compose exec php php artisan octane:status
```

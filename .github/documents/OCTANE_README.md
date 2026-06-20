# Laravel Octane + Swoole в Docker

Этот проект настроен для работы с Laravel Octane и Swoole в Docker-контейнерах.

## Архитектура

- **PHP контейнер**: Запускает Octane через Supervisor на порту 8000
- **Nginx контейнер**: Проксирует запросы к Octane
- **Swoole**: Высокопроизводительный сервер приложений
- **Supervisor**: Управляет процессом Octane
- **Chokidar**: Установлен для file watching в dev режиме

## Конфигурация

### Основные файлы

1. **docker/dockerfiles/php/Dockerfile**
   - Установлен Swoole extension
   - Установлен Node.js и npm
   - Установлен chokidar-cli глобально
   - Установлен socket extension для Swoole

2. **docker/config/php/supervisord-octane.conf**
   - Конфигурация Supervisor для запуска Octane

3. **docker/config/nginx/nginx.conf**
   - Проксирование к Octane (php:8000)

4. **config/octane.php**
   - Настроен для использования Swoole
   - Конфигурация Swoole опций

## Мониторинг

### Проверка работы Swoole

```bash
# Проверить процессы Swoole
docker-compose exec php ps aux | grep swoole

# Посмотреть логи supervisor
docker-compose exec php supervisorctl tail -f octane

# Проверить статистику Swoole
docker-compose exec php php artisan octane:status
```

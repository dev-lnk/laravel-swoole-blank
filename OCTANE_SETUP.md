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
   - 4 worker процесса
   - 6 task worker процессов
   - Максимум 1000 запросов на worker

3. **docker/config/nginx/nginx.conf**
   - Проксирование к Octane (php:8000)
   - Поддержка WebSocket через upgrade headers
   - Оптимизированные таймауты и буферы

4. **config/octane.php**
   - Настроен для использования Swoole
   - Конфигурация Swoole опций
   - File watching для dev режима

## Запуск

### Development режим

```bash
# Пересобрать контейнеры с новой конфигурацией
docker-compose build --no-cache

# Запустить контейнеры
docker-compose up -d

# Проверить логи Octane
docker-compose logs -f php
```

### Доступ к приложению

- **HTTP**: http://localhost:${APP_WEB_PORT}
- **Octane напрямую**: http://localhost:8000 (если нужно обойти nginx)

## Особенности Octane

### File Watching (Dev режим)

Octane может автоматически перезагружать worker'ы при изменении файлов:

```bash
# В контейнере PHP можно запустить с --watch
docker-compose exec php php artisan octane:start --watch
```

Для этого используется установленный chokidar-cli.

### Настройка количества workers

В `docker/config/php/supervisord-octane.conf`:

```ini
# Dev режим - фиксированное количество
--workers=4 --task-workers=6

# Prod режим - автоматически по количеству CPU
--workers=auto --task-workers=auto
```

### Production режим

Для продакшена используйте:

```yaml
volumes:
  - ./docker/config/php/supervisord-octane-prod.conf:/etc/supervisor/conf.d/supervisord.conf
```

## Команды Octane

```bash
# Запустить Octane вручную
docker-compose exec php php artisan octane:start

# Остановить Octane
docker-compose exec php php artisan octane:stop

# Перезапустить Octane
docker-compose exec php php artisan octane:reload

# Проверить статус
docker-compose exec php supervisorctl status

# Перезапустить через supervisor
docker-compose exec php supervisorctl restart octane
```

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

## Troubleshooting

### Octane не запускается

1. Проверьте логи:
```bash
docker-compose logs php
```

2. Проверьте supervisor:
```bash
docker-compose exec php supervisorctl status
```

3. Проверьте права доступа:
```bash
docker-compose exec php ls -la /var/www/app/storage
```

### Nginx возвращает 502

1. Убедитесь, что Octane работает на порту 8000:
```bash
docker-compose exec php netstat -tlnp | grep 8000
```

2. Проверьте upstream в nginx:
```bash
docker-compose exec nginx nginx -t
```

### Изменения не применяются

В dev режиме используйте `--watch` или вручную перезагружайте:
```bash
docker-compose exec php php artisan octane:reload
```

## Переменные окружения

Добавьте в `.env`:

```env
OCTANE_SERVER=swoole
SWOOLE_LOG_LEVEL=2  # SWOOLE_LOG_INFO
```

## Производительность

### Рекомендации для Production

1. **Workers**: Устанавливайте `--workers=auto` для оптимального использования CPU
2. **Max Requests**: Настройте `--max-requests` для предотвращения утечек памяти
3. **Task Workers**: Используйте task workers для длительных операций
4. **Кэширование**: Включите route и config кэширование:

```bash
docker-compose exec php php artisan route:cache
docker-compose exec php php artisan config:cache
docker-compose exec php php artisan view:cache
```

## WebSocket

Nginx уже настроен для проксирования WebSocket соединений через заголовки Upgrade.

## Memory Management

Swoole держит приложение в памяти между запросами:

- ⚠️ Избегайте глобальных переменных
- ⚠️ Очищайте static свойства где необходимо
- ⚠️ Будьте осторожны с singleton сервисами
- ✅ Используйте listeners из `config/octane.php` для очистки состояния

## Дополнительные ресурсы

- [Laravel Octane Documentation](https://laravel.com/docs/12.x/octane)
- [Swoole Documentation](https://www.swoole.co.uk/docs/)
- [Supervisor Documentation](http://supervisord.org/)

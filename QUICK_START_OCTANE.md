# 🚀 Быстрый старт с Laravel Octane + Swoole

## Шаг 1: Подготовка окружения

```bash
# Скопируйте .env.example в .env (если еще не сделали)
cp .env.example .env

# Убедитесь, что в .env есть:
# OCTANE_SERVER=swoole
# SWOOLE_LOG_LEVEL=2
```

## Шаг 2: Сборка контейнеров

```bash
# Пересоберите PHP контейнер со Swoole
docker-compose build --no-cache php

# Или используйте make
make rebuild-app
```

## Шаг 3: Запуск

```bash
# Запустите все сервисы
docker-compose up -d

# Проверьте логи
docker-compose logs -f php
```

## Шаг 4: Проверка

```bash
# Проверьте статус Octane
make octane-status
# Проверьте в браузере
# http://localhost (или ваш APP_WEB_PORT)
```

## ✅ Octane работает, если видите:

```
octane                           RUNNING   pid 123, uptime 0:00:05
```

И процессы Swoole:
```
app-user    123  ... php artisan octane:start --server=swoole ...
```

## 🔧 Основные команды

### Управление через Makefile

```bash
make octane-status      # Статус
make octane-restart     # Перезапуск
make octane-reload      # Перезагрузка workers (без остановки)
make octane-logs        # Логи
make octane-watch       # Запуск с file watching
```

### Прямые команды Docker

```bash
# Войти в контейнер
docker-compose exec php bash

# Запустить Octane вручную
docker-compose exec php php artisan octane:start

# Проверить supervisor
docker-compose exec php supervisorctl status
```

## 🔄 Применение изменений в коде

### Вариант 1: Reload (быстро, без остановки)

```bash
make octane-reload
```

### Вариант 2: Restart (полная перезагрузка)

```bash
make octane-restart
```

### Вариант 3: Watch mode (автоматически)

```bash
make octane-watch
```

## 🐛 Отладка

### Проблема: Octane не запускается

```bash
# 1. Проверьте логи
docker-compose logs php

# 2. Проверьте supervisor
docker-compose exec php supervisorctl status

# 3. Попробуйте запустить вручную
docker-compose exec php php artisan octane:start --server=swoole
```

### Проблема: 502 Bad Gateway

```bash
# 1. Убедитесь что Octane слушает порт 8000
docker-compose exec php netstat -tlnp | grep 8000

# 2. Проверьте nginx конфигурацию
docker-compose exec nginx nginx -t

# 3. Проверьте upstream
docker-compose exec nginx cat /etc/nginx/nginx.conf | grep upstream
```

### Проблема: Изменения не применяются

```bash
# Перезагрузите workers
make octane-reload

# Или используйте watch mode для автоматической перезагрузки
make octane-watch
```

## 📊 Тестирование производительности

```bash
# Apache Bench
ab -n 1000 -c 10 http://localhost/

# Ожидаемый результат:
# Requests per second: 500-2000+ (зависит от приложения)
# Time per request: 0.5-5ms (median)
```

## 🎯 Следующие шаги

1. Прочитайте [OCTANE_SETUP.md](OCTANE_SETUP.md) для детальной документации
2. Прочитайте [MIGRATION_TO_OCTANE.md](MIGRATION_TO_OCTANE.md) для best practices
3. Настройте мониторинг (Laravel Telescope, Horizon)
4. Проведите нагрузочное тестирование
5. Оптимизируйте количество workers для вашей нагрузки

## 💡 Советы

- **Dev режим**: Используйте `--workers=2-4` для экономии ресурсов
- **Prod режим**: Используйте `--workers=auto` для максимальной производительности
- **File watching**: Используйте только в dev режиме
- **Memory leaks**: Настройте `--max-requests=1000` для периодической перезагрузки workers
- **Debugging**: Остановите supervisor и запустите Octane вручную для использования Xdebug

## 🔗 Полезные ссылки

- [README.md](README.md) - Основная документация проекта
- [OCTANE_SETUP.md](OCTANE_SETUP.md) - Детальная настройка Octane
- [MIGRATION_TO_OCTANE.md](MIGRATION_TO_OCTANE.md) - Миграция и best practices
- [Laravel Octane Docs](https://laravel.com/docs/12.x/octane)

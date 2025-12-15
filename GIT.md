# Git Deployment Instructions

## GitHub Secrets

Для работы автоматического деплоя через GitHub Actions необходимо настроить следующие секреты в репозитории:

### Как добавить секреты в GitHub:

1. Перейдите в репозиторий на GitHub
2. Откройте **Settings** → **Secrets and variables** → **Actions**
3. Нажмите **New repository secret**
4. Добавьте следующие секреты:

### Список обязательных секретов:

| Секрет                      | Описание                                                                 | Пример значения        |
|-----------------------------|--------------------------------------------------------------------------|------------------------|
| `PROJECT_NAME`              | Название проекта (используется для именования Docker образов)            | `my-laravel-app`       |
| `DOCKER_HUB_ACCESS_TOKEN`   | Personal Access Token для GitHub Container Registry (ghcr.io)           | `ghp_xxxxxxxxxxxxx`    |

### Как создать DOCKER_HUB_ACCESS_TOKEN:

1. Перейдите в **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Нажмите **Generate new token** → **Generate new token (classic)**
3. Задайте имя токену (например, "Docker Deploy Token")
4. Выберите срок действия токена
5. Установите следующие разрешения (scopes):
   - `write:packages` - для публикации пакетов
   - `read:packages` - для чтения пакетов
   - `delete:packages` - для удаления пакетов (опционально)
6. Нажмите **Generate token**
7. **Важно:** Скопируйте токен сразу, он больше не будет показан!

## Работа с тегами

Workflow автоматического деплоя запускается при создании и пуше тега в репозиторий.

### Создание тега

#### Вариант 1: Создание аннотированного тега (рекомендуется)

```bash
# Создать аннотированный тег с сообщением
git tag -a v1.0.0 -m "Release version 1.0.0"

# Создать тег для конкретного коммита
git tag -a v1.0.0 -m "Release version 1.0.0" <commit-hash>
```

#### Вариант 2: Создание легковесного тега

```bash
# Создать легковесный тег
git tag v1.0.0

# Отправить конкретный тег
git push origin v1.0.0

# Отправить все теги
git push origin --tags
```
## Что происходит при пуше тега

При отправке тега в репозиторий автоматически запускается GitHub Actions workflow (`.github/workflows/deploy.yaml`), который:

1. **Собирает Docker образы:**
   - PostgreSQL Database (`-db`)
   - Nginx Server (`-nginx`)
   - PHP Application (`-php`)
   - Queue Worker (`-worker`)
   - Task Scheduler (`-scheduler`)

2. **Публикует образы в GitHub Container Registry:**
   - Образы доступны по адресу: `ghcr.io/<owner>/<PROJECT_NAME>-<service>:<tag>`
   - Пример: `ghcr.io/myuser/my-laravel-app-php:v1.0.0`

3. **Выполняет деплой** (настраивается в job `deploy`)

## Проверка результатов деплоя

После пуша тега:

1. Перейдите в **Actions** на GitHub
2. Найдите workflow **"Docker Deploy"**
3. Проверьте статус выполнения всех jobs
4. Просмотрите логи в случае ошибок

## Просмотр опубликованных образов

Опубликованные Docker образы можно найти:

1. В репозитории GitHub: **Packages** (справа на странице репозитория)
2. По адресу: `https://github.com/<owner>?tab=packages`
3. Или напрямую: `ghcr.io/<owner>/<package-name>`

## Troubleshooting

### Ошибка аутентификации в GitHub Container Registry

```
Error: denied: permission_denied
```

**Решение:**
- Проверьте, что `DOCKER_HUB_ACCESS_TOKEN` добавлен в секреты
- Убедитесь, что токен имеет права `write:packages`
- Проверьте, что токен не истёк

### Workflow не запускается

**Решение:**
- Убедитесь, что вы отправили тег: `git push origin <tag-name>`
- Проверьте, что workflow файл находится в `.github/workflows/deploy.yaml`
- Убедитесь, что Actions включены в настройках репозитория

### Тег уже существует

```
fatal: tag 'v1.0.0' already exists
```

**Решение:**
- Используйте новую версию тега
- Или удалите старый тег и создайте заново:
  ```bash
  git tag -d v1.0.0
  git push origin --delete v1.0.0
  git tag -a v1.0.0 -m "New message"
  git push origin v1.0.0
  ```

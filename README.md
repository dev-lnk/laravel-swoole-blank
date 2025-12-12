# MoonShine 4 blank project

---

| Settings                         |
|----------------------------------|
| ✅ Enable authentication          |
| ✅ Install with system migrations |
| ✅ Enable notifications           |
| ✅ Base theme                     |

---

| Included        |
|-----------------|
| ✅ Basic setting |
| ✅ PhpStan       |
| ✅ Php CS Fixer  |
| ✅ Rector        |
| ✅ TypeScript    |
| ✅ Xdebug        |
| ✅ Docker        |

## Installation
- Run the git clone command `git clone git@github.com:dev-lnk/moonshine-blank.git .`.
- Copy the `.env.example` file and rename it to `.env`, customize the `#Docker` section to your needs.
- Run the command `make init`.
- Check the application's operation using the link `http://localhost/admin` or `http://localhost:${APP_WEB_PORT}/admin`.
- Run stat analysis and tests using the command `make check`.

## ⚡ Laravel Octane + Swoole
This project is configured to run with Laravel Octane and Swoole for high performance.

### Features
- ✅ Swoole server with supervisor
- ✅ Nginx reverse proxy to Swoole
- ✅ File watching with chokidar (dev mode)
- ✅ Auto workers configuration
- ✅ WebSocket support

### Quick Start
```bash
# Rebuild containers with Octane support
docker-compose build --no-cache php && docker-compose up -d

# Check status
make octane-status  # or ./octane.sh status

# Reload workers after code changes
make octane-reload  # or ./octane.sh reload
```

## About
This is a Blank MoonShine 4 based on the [laravel-blank](https://github.com/dev-lnk/laravel-blank) project.

### Other
- Many commands to speed up development and work with docker can be found in the `Makefile`
- If you don't need Docker, remove: `/docker`, `docker-compose.yml`, `Makefile`. Convert `.env` to standard Laravel form
- To launch containers with `worker` and `scheduler`, delete comments on the corresponding blocks in `docker-compose.yml`
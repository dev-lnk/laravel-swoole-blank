#!/bin/bash

# Скрипт для управления Laravel Octane в Docker

CONTAINER_NAME="${COMPOSE_PROJECT_NAME:-moonshine-blank}-php"

case "$1" in
    start)
        echo "Starting Octane..."
        docker-compose exec php supervisorctl start octane
        ;;
    stop)
        echo "Stopping Octane..."
        docker-compose exec php supervisorctl stop octane
        ;;
    restart)
        echo "Restarting Octane..."
        docker-compose exec php supervisorctl restart octane
        ;;
    reload)
        echo "Reloading Octane workers..."
        docker-compose exec php php artisan octane:reload
        ;;
    status)
        echo "Octane status:"
        docker-compose exec php supervisorctl status octane
        echo ""
        echo "Swoole processes:"
        docker-compose exec php ps aux | grep swoole
        ;;
    logs)
        echo "Octane logs (tail):"
        docker-compose exec php supervisorctl tail -f octane
        ;;
    watch)
        echo "Starting Octane with file watching..."
        echo "Note: This will run in foreground. Press Ctrl+C to stop."
        docker-compose exec php php artisan octane:start --watch --server=swoole --host=0.0.0.0 --port=8000
        ;;
    build)
        echo "Building Docker images with Octane support..."
        docker-compose build --no-cache php
        ;;
    up)
        echo "Starting all services..."
        docker-compose up -d
        docker-compose logs -f php
        ;;
    *)
        echo "Laravel Octane management script"
        echo ""
        echo "Usage: $0 {start|stop|restart|reload|status|logs|watch|build|up}"
        echo ""
        echo "Commands:"
        echo "  start    - Start Octane via supervisor"
        echo "  stop     - Stop Octane"
        echo "  restart  - Restart Octane"
        echo "  reload   - Reload Octane workers (apply code changes)"
        echo "  status   - Show Octane status and processes"
        echo "  logs     - Show Octane logs"
        echo "  watch    - Start Octane with file watching (dev mode)"
        echo "  build    - Rebuild Docker images"
        echo "  up       - Start all Docker services"
        exit 1
        ;;
esac

exit 0

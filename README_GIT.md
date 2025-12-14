# GitHub Secrets Configuration Guide

This guide explains how to set up GitHub Secrets for automatic Docker image building and deployment.

## Overview

The CI/CD pipeline automatically builds Docker images when you push a git tag and pushes them to Docker Hub. The deployment workflow is configured in `.github/workflows/deploy.yaml`.

## Required GitHub Secrets

Navigate to your GitHub repository settings:
**Settings → Secrets and variables → Actions → New repository secret**

### 1. Docker Hub Credentials

#### `DOCKER_HUB_USERNAME`
- **Description**: Your Docker Hub username
- **Example**: `myusername`
- **Where to find**: https://hub.docker.com/ (your account name)

#### `DOCKER_HUB_ACCESS_TOKEN`
- **Description**: Docker Hub access token for authentication
- **How to create**:
  1. Go to https://hub.docker.com/settings/security
  2. Click "New Access Token"
  3. Give it a name (e.g., "GitHub Actions laravel-swoole-blank")
  4. Select permissions: "Read, Write, Delete"
  5. Copy the generated token (you won't see it again!)
- **Security**: Never commit this token to your repository

---

## Workflow Process

### 1. Building and Pushing Images

When you create and push a git tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically:
1. Build 5 Docker images:
   - `laravel-swoole-blank-db` (PostgreSQL database)
   - `laravel-swoole-blank-nginx` (Nginx web server)
   - `laravel-swoole-blank-php` (Laravel Octane with Swoole)
   - `laravel-swoole-blank-worker` (Queue worker)
   - `laravel-swoole-blank-scheduler` (Laravel scheduler)
2. Tag them with your git tag (e.g., `v1.0.0`)
3. Push them to Docker Hub

### 2. Deploying on Server

After images are pushed to Docker Hub, deploy them on your production server:

```bash
# SSH to your production server
ssh user@your-server.com

# Navigate to project directory
cd /path/to/laravel-swoole-blank

# Run deployment script with the tag
sudo ./deploy.sh v1.0.0
```

The `deploy.sh` script will:
- Update `.env` with the new image tag
- Pull the new images from Docker Hub
- Stop old containers
- Start new containers
- Clean up old images

---

## Production Server Setup

### 1. Prerequisites on Server

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Add your user to docker group (optional)
sudo usermod -aG docker $USER
```

### 2. Initial Setup

```bash
# Clone repository (or copy files)
git clone https://github.com/yourusername/laravel-swoole-blank.git
cd laravel-swoole-blank

# Copy and configure .env file
cp .env.production.example .env
nano .env

# Important: Update these values in .env:
# - DOCKER_HUB_USER=your_dockerhub_username
# - IMAGE_TAG=v1.0.0
# - POSTGRES_PASSWORD=secure_password
# - APP_KEY (generate with: php artisan key:generate)
# - APP_URL=https://your-domain.com

# Make deploy script executable
chmod +x deploy.sh
```

### 3. First Deployment

```bash
# Pull initial images
docker-compose -f docker-compose.prod.yml pull

# Start containers
make up-prod

# Check status
make ps-prod

# View logs
make logs-prod
```

---

## Deployment Commands Reference

### Using Makefile

```bash
# Start production containers
make up-prod

# Stop production containers
make stop-prod

# View production logs
make logs-prod

# Check container status
make ps-prod

# Deploy with specific tag
make deploy t=v1.0.0
```

### Manual Docker Compose Commands

```bash
# Start containers
docker-compose -f docker-compose.prod.yml up -d

# Stop containers
docker-compose -f docker-compose.prod.yml stop

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Restart specific service
docker-compose -f docker-compose.prod.yml restart php
```

---

## Environment Variables

Key environment variables in production `.env`:

```bash
# Docker configuration
COMPOSE_PROJECT_NAME=laravel-swoole-blank
DOCKER_HUB_USER=your_dockerhub_username
IMAGE_TAG=v1.0.0

# Database
POSTGRES_PASSWORD=your_secure_password
DB_DATABASE=laravel-swoole-blank_production

# Laravel
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:generated_key_here
APP_URL=https://your-domain.com
```

---

## Troubleshooting

### Images not pulling
```bash
# Login to Docker Hub manually
docker login

# Verify credentials
docker pull your_dockerhub_username/laravel-swoole-blank-php:v1.0.0
```

### Container won't start
```bash
# Check logs
docker logs laravel-swoole-blank-php

# Check container status
docker ps -a | grep laravel-swoole-blank

# Restart specific container
docker restart laravel-swoole-blank-php
```

### Database connection issues
```bash
# Check database container
docker logs laravel-swoole-blank-db

# Verify network
docker network ls
docker network inspect laravel-swoole-blank_default

# Test connection from PHP container
docker exec laravel-swoole-blank-php pg_isready -h laravel-swoole-blank-db -U postgres
```

### Permission issues
```bash
# Fix storage permissions
docker exec laravel-swoole-blank-php chown -R www-data:www-data /var/www/app/storage
docker exec laravel-swoole-blank-php chmod -R 775 /var/www/app/storage
```

---

## Security Best Practices

1. **Never commit sensitive data** to the repository
2. **Use strong passwords** for database and other services
3. **Keep secrets secure** in GitHub Secrets
4. **Regularly update** Docker images and dependencies
5. **Use HTTPS** in production (set up SSL/TLS)
6. **Rotate access tokens** periodically
7. **Backup database** regularly

---

## Useful Links

- [Docker Hub](https://hub.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Laravel Deployment Documentation](https://laravel.com/docs/deployment)

---

## Support

For issues or questions:
1. Check container logs: `make logs-prod`
2. Verify GitHub Actions workflow status
3. Check Docker Hub for pushed images
4. Review this documentation

---

## Quick Reference

### Create and push a new release
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Deploy on server
```bash
ssh user@server
cd /path/to/laravel-swoole-blank
sudo ./deploy.sh v1.0.0
```

### Rollback to previous version
```bash
sudo ./deploy.sh v0.9.9
```

---

**Last Updated**: December 2025

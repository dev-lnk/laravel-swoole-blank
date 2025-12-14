#!/bin/bash

set -e

CONFIG_FILE="./.env"
NEW_IMAGE_TAG=$1
COMPOSE_PROJECT_NAME=$(grep "^COMPOSE_PROJECT_NAME=" "$CONFIG_FILE" | cut -d '=' -f2)

echo "========================================="
echo "Production Deployment Script"
echo "========================================="
echo "Tag: $NEW_IMAGE_TAG"
echo "Project: $COMPOSE_PROJECT_NAME"
echo "========================================="

# Check if tag is provided
if [ -z "$NEW_IMAGE_TAG" ]; then
  echo "Error: No image tag provided"
  echo "Usage: ./deploy.sh <tag>"
  exit 1
fi

# Check if .env file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Configuration file $CONFIG_FILE not found"
  exit 1
fi

# Update IMAGE_TAG in .env file
if grep -q "^IMAGE_TAG=" "$CONFIG_FILE"; then
  echo "Updating IMAGE_TAG to $NEW_IMAGE_TAG in $CONFIG_FILE"
  sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=$NEW_IMAGE_TAG/" "$CONFIG_FILE"
else
  echo "Warning: IMAGE_TAG not found in $CONFIG_FILE, adding it"
  echo "IMAGE_TAG=$NEW_IMAGE_TAG" >> "$CONFIG_FILE"
fi

# Stop running containers
echo "Stopping production containers..."
make stop-prod || true

# Pull new images
echo "Pulling new Docker images..."
docker-compose -f docker-compose.prod.yml pull

# Remove old containers (only project-specific ones)
echo "Removing old containers..."
docker container rm -f $(docker ps -a -q --filter "name=${COMPOSE_PROJECT_NAME}") 2>/dev/null || true

# Clean up unused images
echo "Cleaning up unused images..."
docker image prune -f

# Start containers with new images
echo "Starting production containers..."
make up-prod

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Check container status
echo "Checking container status..."
docker-compose -f docker-compose.prod.yml ps

# Run migrations (optional, uncomment if needed)
# echo "Running database migrations..."
# docker exec ${COMPOSE_PROJECT_NAME}-php php artisan migrate --force

# Clear cache (optional, uncomment if needed)
# echo "Clearing application cache..."
# docker exec ${COMPOSE_PROJECT_NAME}-php php artisan optimize:clear
# docker exec ${COMPOSE_PROJECT_NAME}-php php artisan config:cache
# docker exec ${COMPOSE_PROJECT_NAME}-php php artisan route:cache
# docker exec ${COMPOSE_PROJECT_NAME}-php php artisan view:cache

echo "========================================="
echo "Deployment completed successfully!"
echo "========================================="
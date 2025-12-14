-include .env

THIS_FILE := $(lastword $(MAKEFILE_LIST))

app := $(COMPOSE_PROJECT_NAME)-php
nginx := $(COMPOSE_PROJECT_NAME)-nginx
postgres := $(COMPOSE_PROJECT_NAME)-db
app-npm := npm
path := /var/www/app
run := docker exec --user app-user $(app)

#docker
.PHONY: init
init: build install

.PHONY: build
build:
	docker-compose -f docker-compose.yml up --build -d $(c)
	@echo "Run command: make install"
	@echo "$(APP_URL)"

.PHONY: install
install: composer-install composer-update migrate-fresh npm-install npm-update npm-build restart-worker check
	@echo "$(APP_URL)"

.PHONY: rebuild
rebuild:
	docker compose down --remove-orphans
	IMAGES=$$(docker images --filter=reference="$(COMPOSE_PROJECT_NAME)*:*" -q); \
	if [ -n "$$IMAGES" ]; then docker rmi $$IMAGES -f; else echo "No images to remove"; fi
	make build

.PHONY: rebuild-app
rebuild-app:
	docker-compose up -d --force-recreate --no-deps --build php

.PHONY: restart-worker
restart-worker:
	docker restart $(COMPOSE_PROJECT_NAME)-worker

#octane
.PHONY: octane-start
octane-start:
	$(run) supervisorctl start octane

.PHONY: octane-stop
octane-stop:
	$(run) supervisorctl stop octane

.PHONY: octane-restart
octane-restart:
	$(run) supervisorctl restart octane

.PHONY: octane-reload
octane-reload:
	$(run) php artisan octane:reload

.PHONY: octane-status
octane-status:
	$(run) supervisorctl status octane
	$(run) ps aux | grep swoole

.PHONY: octane-logs
octane-logs:
	$(run) supervisorctl tail -f octane

.PHONY: octane-watch
octane-watch:
	$(run) php artisan octane:start --watch --server=swoole --host=0.0.0.0 --port=8000

.PHONY: up
up:
	docker-compose -f docker-compose.yml up -d $(c)
	@echo "$(APP_URL)"

.PHONY: stop
stop:
	docker-compose -f docker-compose.yml stop $(c)

.PHONY: it
it:
	docker exec -it $(to) /bin/bash

.PHONY: it-app
it-app:
	docker exec -it --user app-user $(app) /bin/bash

.PHONY: it-nginx
it-nginx:
	docker exec -it $(nginx) /bin/bash

.PHONY: it-postgres
it-postgres:
	docker exec -it $(postgres) /bin/bash

.PHONY: migrate
migrate:
	$(run) php artisan migrate

.PHONY: migrate-rollback
migrate-rollback:
	$(run) php artisan migrate:rollback

.PHONY: migrate-fresh
migrate-fresh:
	$(run) php artisan migrate:fresh --seed

.PHONY: migration
migration:
	$(run) php artisan make:migration $(m)

#composer
.PHONY: composer-install
composer-install:
	$(run) composer install

.PHONY: composer-update
composer-update:
	$(run) composer update

.PHONY: composer-du
composer-du:
	$(run) composer du

#Tools
.PHONY: test
test:
	$(run) php artisan test

.PHONY: rector
rector:
	$(run) tools/rector/vendor/bin/rector process --dry-run

.PHONY: fix-rector
fix-rector:
	$(run) tools/rector/vendor/bin/rector process

.PHONY: analyse
analyse:
	$(run) php -d memory_limit=-1 tools/larastan/vendor/bin/phpstan analyse -c phpstan.neon

.PHONY: fixcs
fixcs:
	$(run) tools/php-cs-fixer/vendor/bin/php-cs-fixer fix --config=.php-cs-fixer.dist.php

.PHONY: lint
lint:
	$(run) tools/php-cs-fixer/vendor/bin/php-cs-fixer fix --config=.php-cs-fixer.dist.php --dry-run

.PHONY: check
check: rector lint analyse test

#npm
.PHONY: npm
npm:
	$(run) npm $(c)

.PHONY: npm-install
npm-install:
	$(run) npm install $(c)

.PHONY: npm-update
npm-update:
	$(run) npm update $(c)

.PHONY: npm-build
npm-build:
	$(run) npm run build $(c)

.PHONY: npm-host
npm-host:
	$(run) npm run dev --host $(c)

#production
.PHONY: build-prod
build-prod:
	docker-compose -f docker-compose.prod.yml up --build -d $(c)

.PHONY: up-prod
up-prod:
	docker-compose -f docker-compose.prod.yml up -d $(c)

.PHONY: stop-prod
stop-prod:
	docker-compose -f docker-compose.prod.yml stop $(c)

.PHONY: down-prod
down-prod:
	docker-compose -f docker-compose.prod.yml down $(c)

.PHONY: logs-prod
logs-prod:
	docker-compose -f docker-compose.prod.yml logs -f $(c)

.PHONY: ps-prod
ps-prod:
	docker-compose -f docker-compose.prod.yml ps

.PHONY: deploy
deploy:
	sudo ./deploy.sh $(t)
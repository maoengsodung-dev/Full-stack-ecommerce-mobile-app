.PHONY: help build up down restart logs ps prod-build prod-up prod-down prod-logs dev-build dev-up dev-down dev-logs migrate seed optimize clean

help:
	@echo "Laravel Docker Management"
	@echo "========================="
	@echo "Development Commands:"
	@echo "  make dev-build    - Build dev containers"
	@echo "  make dev-up       - Start dev environment"
	@echo "  make dev-down     - Stop dev environment"
	@echo "  make dev-logs     - View dev logs"
	@echo ""
	@echo "Production Commands:"
	@echo "  make prod-build   - Build prod containers"
	@echo "  make prod-up     - Start prod environment"
	@echo "  make prod-down   - Stop prod environment"
	@echo "  make prod-logs   - View prod logs"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make migrate      - Run migrations"
	@echo "  make seed         - Run seeders"
	@echo "  make optimize     - Clear and cache"
	@echo "  make clean        - Remove containers and volumes"

# Development commands
dev-build:
	cp .env.docker .env
	docker-compose build

dev-up:
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	@echo "Waiting for MySQL to be healthy..."
	@docker-compose exec -T db wait-for-it localhost:3306 -- timeout=60 || true
	docker-compose exec -T app composer install --no-interaction
	docker-compose exec -T app php artisan key:generate --no-interaction
	docker-compose exec -T app php artisan migrate:fresh --seed --no-interaction

dev-down:
	docker-compose down

dev-logs:
	docker-compose logs -f

# Production commands
prod-build:
	cp .env.prod .env
	docker-compose -f docker-compose.prod.yml build --no-cache

prod-up:
	docker-compose -f docker-compose.prod.yml up -d
	@echo "Waiting for services to be ready..."
	@sleep 5
	docker-compose -f docker-compose.prod.yml exec -T app php artisan key:generate
	docker-compose -f docker-compose.prod.yml exec -T app php artisan migrate --force

prod-down:
	docker-compose -f docker-compose.prod.yml down

prod-logs:
	docker-compose -f docker-compose.prod.yml logs -f

# Utility commands
migrate:
	docker-compose exec -T app php artisan migrate

migrate-fresh:
	docker-compose exec -T app php artisan migrate:fresh --seed

seed:
	docker-compose exec -T app php artisan db:seed

optimize:
	docker-compose exec -T app php artisan config:cache
	docker-compose exec -T app php artisan route:cache
	docker-compose exec -T app php artisan view:cache
	docker-compose exec -T app php artisan optimize

clean:
	docker-compose down -v
	docker-compose -f docker-compose.prod.yml down -v
	@echo "Containers and volumes removed"

logs:
	docker-compose logs -f

ps:
	docker-compose ps

shell:
	docker-compose exec app sh

artisan:
	docker-compose exec app php artisan $(filter-out $@,$(MAKECMDGOALS)))
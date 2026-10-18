# Docker Deployment Guide

This project includes Docker configuration for both development and production environments.

## Quick Start

### Development Environment

```bash
# 1. Copy the development environment file
cp .env.docker .env

# 2. Build and start the containers
make dev-build
make dev-up

# 3. Access the application
# API: http://localhost:8000
# MySQL: localhost:3306
# Redis: localhost:6379
```

### Production Environment

```bash
# 1. Copy the production environment file
cp .env.prod .env

# 2. Update the .env file with your actual production values:
# - APP_KEY (run: php artisan key:generate)
# - DB_PASSWORD
# - PAYWAY credentials
# - FCM_KEY

# 3. Build and start the production containers
make prod-build
make prod-up
```

## Available Commands

| Command           | Description                       |
| ----------------- | --------------------------------- |
| `make dev-build`  | Build dev containers              |
| `make dev-up`     | Start dev environment             |
| `make dev-down`   | Stop dev environment              |
| `make dev-logs`   | View dev logs                     |
| `make prod-build` | Build prod containers             |
| `make prod-up`    | Start prod environment            |
| `make prod-down`  | Stop prod environment             |
| `make prod-logs`  | View prod logs                    |
| `make migrate`    | Run migrations                    |
| `make seed`       | Run seeders                       |
| `make optimize`   | Clear and cache config            |
| `make clean`      | Remove all containers and volumes |
| `make shell`      | Access container shell            |

## Services

### Development

- **App**: PHP-FPM on port 8000
- **Nginx**: Web server on port 80
- **MySQL**: Database on port 3306
- **Redis**: Cache on port 6379
- **Horizon**: Queue worker

### Production

- Same services with production-optimized settings

## Environment Variables

### Development (.env.docker)

- `APP_DEBUG=true`
- `APP_ENV=local`
- Database: root/root

### Production (.env.prod)

- `APP_DEBUG=false`
- `APP_ENV=production`
- Database: laravel_user/secure_password_here

## Manual Commands

If you don't want to use Make:

```bash
# Development
docker-compose build
docker-compose up -d
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate:fresh --seed

# Production
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs

# Rebuild without cache
docker-compose build --no-cache
```

### Database connection issues

```bash
# Check if MySQL is ready
docker-compose logs db

# Restart services
docker-compose restart
```

### Clear all data

```bash
make clean
```

## SSL/HTTPS (Production)

To enable HTTPS in production, update `nginx.conf` with your SSL certificate paths:

```nginx
server {
    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    # ...
}
```

Then uncomment the SSL-related lines in `Dockerfile.nginx`.

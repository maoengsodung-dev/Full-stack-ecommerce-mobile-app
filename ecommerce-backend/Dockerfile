# Development stage
FROM php:8.4-fpm AS development

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    supervisor \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Redis extension
RUN pecl install redis-6.2.0 \
    && docker-php-ext-enable redis

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . /var/www

# Install development dependencies
RUN composer install --prefer-dist --ignore-platform-reqs

# Expose port 9000
EXPOSE 9000

CMD ["php-fpm"]

# Production stage
FROM php:8.4-fpm AS production

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    supervisor \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Redis extension
RUN pecl install redis-6.2.0 \
    && docker-php-ext-enable redis

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . /var/www

# Install production dependencies (no dev packages)
RUN composer install --optimize-autoloader --no-dev --no-interaction --ignore-platform-reqs

# NOTE: config/route caching is intentionally NOT done here.
# Baking cached config at build time captures build-time env values
# (e.g. REDIS_HOST=127.0.0.1) instead of the runtime Docker env.
# Cache is warmed at container startup via docker-compose command or entrypoint.

# Expose port 9000
EXPOSE 9000

CMD ["php-fpm"]

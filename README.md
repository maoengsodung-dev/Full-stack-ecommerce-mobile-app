# 🚀 Full-Stack E-Commerce Mobile App & Backend Solution

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.10.4-blue.svg?logo=flutter)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-11.x-red.svg?logo=laravel)](https://laravel.com)
[![GetX](https://img.shields.io/badge/Architecture-GetX-brightgreen.svg)](./architecture_getx/README.md)
[![Riverpod](https://img.shields.io/badge/Architecture-Riverpod%202.x-0553B1.svg)](./ecommerce_riverpod/README.md)
[![Payment](<https://img.shields.io/badge/Payment-ABA%20PayWay%20(KHQR)-005F86.svg>)](https://www.ababank.com)
[![Firebase](https://img.shields.io/badge/Firebase-FCM%20%7C%20Auth%20%7C%20Firestore-orange.svg?logo=firebase)](https://firebase.google.com)

A complete, production-ready **Full-Stack E-Commerce Suite** consisting of two modern Flutter mobile client architectures (GetX and Riverpod) and a robust Laravel 11 REST API backend.

---

## 📚 Project Documentation

Each component within this monorepo has its own comprehensive documentation:

| Project                                                        | Technology                        | Details & Architecture                                                                           |                     Readme Link                      |
| :------------------------------------------------------------- | :-------------------------------- | :----------------------------------------------------------------------------------------------- | :--------------------------------------------------: |
| [📱 **`architecture_getx/`**](./architecture_getx/README.md)   | Flutter 3.10+, GetX, Dio          | GetX Reactive State, Dependency Injection, GetPage routes, Admin Control Tower, and ABA PayWay.  | [📖 **View Readme**](./architecture_getx/README.md)  |
| [📱 **`ecommerce_riverpod/`**](./ecommerce_riverpod/README.md) | Flutter 3.10+, Riverpod 2.x, Dio  | Riverpod Notifiers, Immutable State, Clean Architecture + Feature-First (DDD), and Route Guards. | [📖 **View Readme**](./ecommerce_riverpod/README.md) |
| [🌐 **`ecommerce-backend/`**](./ecommerce-backend/README.md)   | Laravel 11, PHP 8.3, MySQL, Redis | Full REST API, Sanctum Auth, Spatie Roles, FCM Notifications, PayWay Webhooks, and Docker.       | [📖 **View Readme**](./ecommerce-backend/README.md)  |

---

## 📦 Projects Overview & Direct Links

Click any project link below to view its complete documentation:

- 📱 [**`architecture_getx/`**](./architecture_getx/README.md) — _Flutter Mobile App (GetX Clean Architecture)_  
  👉 **[📖 Open `architecture_getx/README.md`](./architecture_getx/README.md)**

- 📱 [**`ecommerce_riverpod/`**](./ecommerce_riverpod/README.md) — _Flutter Mobile App (Riverpod 2.x Feature-First Architecture)_  
  👉 **[📖 Open `ecommerce_riverpod/README.md`](./ecommerce_riverpod/README.md)**

- 🌐 [**`ecommerce-backend/`**](./ecommerce-backend/README.md) — _Backend REST API (Laravel 11, MySQL, Redis, Docker)_  
  👉 **[📖 Open `ecommerce-backend/README.md`](./ecommerce-backend/README.md)**

---

## ✨ System Features

### 🛍️ Mobile Applications (Flutter)

- **Dual Architecture Implementations**: Compare side-by-side GetX vs Riverpod 2.x on identical business requirements.
- **Customer Storefront**:
  - Interactive catalog, dynamic banners carousel, horizontal category selector.
  - Multi-image product gallery, variant management (sizes, colors, SKUs).
  - Real-time search with history and multi-criteria filter bottom sheets.
  - Dynamic shopping bag with promo code discounts (`FALL20`) and accurate tax/subtotal calculation.
  - Interactive Google Maps address selector with GPS location and reverse geocoding.
  - Order tracking with timeline and colored status badges (`Pending`, `Processing`, `Shipped`, `Delivered`, `Cancelled`).
  - Offline-first cached wishlist with instant synchronization.
- **Admin Control Tower**:
  - Dedicated administrative dashboard protected by role-based route guards (`AdminMiddleware` / `RouteGuards.isAdmin`).
  - Catalog management: Create and update products, categories, variants, and banners.
  - Order fulfillment workflow: Transition order states and review invoices.
- **Payment Gateway**:
  - Seamless integration with **ABA PayWay (Cambodia)**.
  - Real-time **KHQR** generation, deep-linking into native ABA Mobile banking app, in-app WebView fallback, and verification polling.
  - Dynamic USD/KHR currency conversion.
- **Multi-Flavor Environments**:
  - `dev`, `staging`, and `prod` with colored diagnostic ribbon banners.
- **Internationalization (i18n)**:
  - 6 languages supported: English (`en`), Khmer (`km` with Google Fonts Battambang), Japanese (`ja`), Korean (`ko`), Vietnamese (`vi`), Chinese (`zh`).

### 🌐 Backend Services (Laravel 11)

- Token-based API authentication (Sanctum / JWT).
- Role-based Access Control (Customer vs Admin).
- Relational schema with migrations, factories, and seeders.
- FCM push notification triggers for order updates.
- Docker & Docker Compose setup for local and production deployment.

---

## 🚀 Quick Start Guide

### 1. Backend Setup ([`ecommerce-backend/`](./ecommerce-backend/README.md))

```bash
cd ecommerce-backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### 2. Mobile App Setup ([`architecture_getx/`](./architecture_getx/README.md) or [`ecommerce_riverpod/`](./ecommerce_riverpod/README.md))

```bash
# Choose either client:
cd architecture_getx
# or: cd ecommerce_riverpod

# Setup environment
cp .env.example .env

# Install packages & generate localization
flutter pub get
flutter gen-l10n

# Run development flavor
flutter run --flavor dev -t lib/main.dart --dart-define-from-file=.env
```

---

## 📄 License

Proprietary software developed for the E-Commerce platform. All rights reserved.

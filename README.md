# 🚀 Full-Stack E-Commerce Mobile App & Backend Solution

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.10.4-blue.svg?logo=flutter)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-11.x-red.svg?logo=laravel)](https://laravel.com)
[![GetX](https://img.shields.io/badge/Architecture-GetX-brightgreen.svg)](architecture_getx/README.md)
[![Riverpod](https://img.shields.io/badge/Architecture-Riverpod%202.x-0553B1.svg)](ecommerce_riverpod/README.md)
[![Payment](https://img.shields.io/badge/Payment-ABA%20PayWay%20(KHQR)-005F86.svg)](https://www.ababank.com)
[![Firebase](https://img.shields.io/badge/Firebase-FCM%20%7C%20Auth%20%7C%20Firestore-orange.svg?logo=firebase)](https://firebase.google.com)

A complete, production-ready **Full-Stack E-Commerce Suite** consisting of two modern Flutter mobile client architectures (GetX and Riverpod) and a robust Laravel 11 REST API backend.

---

## 📦 Projects Overview

This repository is organized as a multi-project monorepo containing three core components:

```
E-commerce-mobile-app/
├── architecture_getx/   # 📱 Flutter Mobile App (GetX Clean Architecture)
├── ecommerce_riverpod/  # 📱 Flutter Mobile App (Riverpod 2.x Feature-First)
└── ecommerce-backend/   # 🌐 Backend REST API (Laravel 11, MySQL, Docker)
```

| Component | Technology | Description | Documentation |
| :--- | :--- | :--- | :--- |
| **`architecture_getx/`** | Flutter 3.10+, Dart 3, GetX, Dio | Mobile storefront & Admin dashboard built with GetX reactive state management, runtime DI, and GetPage routing. | [Read README](architecture_getx/README.md) |
| **`ecommerce_riverpod/`** | Flutter 3.10+, Dart 3, Riverpod 2.x, Dio | Companion mobile application built with compile-time safe Riverpod state management, Clean Architecture + Feature-First (DDD). | [Read README](ecommerce_riverpod/README.md) |
| **`ecommerce-backend/`** | Laravel 11, PHP 8.2+, MySQL, Docker | Full REST API handling authentication, product catalog, categories, orders, carts, notifications, and ABA PayWay webhooks. | [Read README](ecommerce-backend/README.md) |

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

### 1. Backend Setup (`ecommerce-backend`)
```bash
cd ecommerce-backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### 2. Mobile App Setup (`architecture_getx` or `ecommerce_riverpod`)
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

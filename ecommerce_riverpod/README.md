# 🛍️ E-Commerce Mobile Application — Flutter Riverpod Edition

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.10.4-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%5E3.10.4-0175C2.svg?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-brightgreen.svg)](https://riverpod.dev)
[![State Management](https://img.shields.io/badge/State%20Management-Riverpod%202.x-0553B1.svg?logo=flutter)](https://pub.dev/packages/flutter_riverpod)
[![Backend](https://img.shields.io/badge/Backend-Laravel%2011%20REST%20API-red.svg?logo=laravel)](https://laravel.com)
[![Firebase](https://img.shields.io/badge/Firebase-FCM%20%7C%20Auth%20%7C%20Firestore-orange.svg?logo=firebase)](https://firebase.google.com)
[![Payment](<https://img.shields.io/badge/Payment-ABA%20PayWay%20(KHQR)-005F86.svg>)](https://www.ababank.com)
[![Localization](https://img.shields.io/badge/Languages-EN%20%7C%20KM%20%7C%20JA%20%7C%20KO%20%7C%20VI%20%7C%20ZH-purple.svg)](#-internationalization--localization)

A modern, production-grade **E-Commerce Mobile Application** built with **Flutter** and powered by **Flutter Riverpod (Clean Architecture & Feature-First Pattern)**. This codebase represents the compile-time safe, reactive companion to the GetX version, sharing the same **Laravel 11 REST API** backend, Firebase infrastructure, ABA PayWay payment gateway, and multi-flavor setup.

---

## 📑 Table of Contents

- [Architectural Overview](#-architectural-overview)
- [Key Features](#-key-features)
  - [Customer Storefront](#1-customer-storefront)
  - [Admin Control Tower](#2-admin-control-tower)
- [Riverpod State Management Architecture](#-riverpod-state-management-architecture)
- [Tech Stack & Dependencies](#-tech-stack--dependencies)
- [Project Directory Structure](#-project-directory-structure)
- [Navigation & Route Guards](#-navigation--route-guards)
- [Multi-Flavor Setup](#-multi-flavor-setup)
- [Environment Configuration (.env)](#-environment-configuration-env)
- [Internationalization & Localization](#-internationalization--localization)
- [Core Infrastructure & Services](#-core-infrastructure--services)
  - [Networking & Dio Client](#networking--dio-client)
  - [Persistent Storage & Caching](#persistent-storage--caching)
  - [Push & Local Notifications](#push--local-notifications)
  - [ABA PayWay & KHQR Payment](#aba-payway--khqr-payment)
- [API Integration Reference](#-api-integration-reference)
- [Installation & Getting Started](#-installation--getting-started)
- [Useful Commands](#-useful-commands)

---

## 🏛️ Architectural Overview

The application follows the **Feature-First Clean Architecture** with **Domain-Driven Design (DDD)** principles:

```
lib/
├── app/
│   ├── core/         # Global foundation: Config, Router, Network, Theme, Services
│   └── data/         # Shared data models, API providers, and repositories
└── features/         # Self-contained domain modules
    ├── <feature>/
    │   ├── data/             # Remote sources & repository implementations
    │   ├── domain/           # Business entities & usecases
    │   └── presentation/     # UI Pages, Riverpod Notifiers, Custom Widgets
```

```
┌──────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│      ConsumerWidget / ConsumerStatefulWidget                     │
│      ref.watch() / ref.read() / ref.listen()                     │
└─────────────────────────────────┬────────────────────────────────┘
                                  │
┌─────────────────────────────────▼────────────────────────────────┐
│                     Riverpod Providers & State                   │
│   NotifierProvider / AsyncNotifierProvider / StateProvider       │
│   Immutable State Models & AsyncValue<T>                         │
└─────────────────────────────────┬────────────────────────────────┘
                                  │
┌─────────────────────────────────▼────────────────────────────────┐
│                       Domain & Use Cases                         │
│   Business Entities, Validation, and Repository Contracts        │
└─────────────────────────────────┬────────────────────────────────┘
                                  │
┌─────────────────────────────────▼────────────────────────────────┐
│                        Data Access Layer                         │
│   Repositories  ◄───►  Dio ApiClient  ◄───►  StorageService      │
└──────────────────────────────────────────────────────────────────┘
```

### Why Riverpod Architecture?

1. **Compile-Time Safety**: No runtime `Get.find<T>()` errors or type mismatches. Dependencies are resolved at compile time.
2. **Unidirectional Data Flow**: State is immutable (`copyWith`) and changes are tracked through explicit `Notifier<T>` methods.
3. **Widget Rebuild Optimization**: Using `ref.watch(provider.select(...))` minimizes unnecessary UI rebuilds.
4. **Testability**: Riverpod providers can be effortlessly overridden in unit and integration tests using `ProviderScope(overrides: [...])`.

---

## ✨ Key Features

### 1. Customer Storefront

- **Splash & Smart Routing**: Instant authentication check upon boot with automatic routing to the store shell or auth screens.
- **Persistent Floating Shell**: Frosted-glass navigation bar preserving state across 5 tabs with `IndexedStack`:
  - 🏠 **Home** (Catalog, banners, search, filtering)
  - 💖 **Wishlist** (Saved favorites with badge count)
  - 🛒 **Cart** (Shopping bag with dynamic live counter)
  - 📦 **Orders** (Order history and tracking)
  - 👤 **Profile** (Account settings, language, role switch)
- **Home & Catalog**:
  - Dynamic carousel banners with auto-play and page indicators.
  - Category filter pills with reactive product updates.
  - High-performance product cards with discount ribbons, ratings, price calculation, and quick favorite toggles.
- **Search & Advanced Filtering**:
  - Live search suggestions with local recent searches cache.
  - Multi-criteria filter modal: Price range, Category, Ratings, and Sorting (Newest, Price Low-High, Rating).
- **Product Details**:
  - High-resolution zoomable image carousel.
  - Variant selection (Size, Color, SKU).
  - Real-time stock status check and low-inventory warnings.
  - Dynamic price calculations and cart quantity increments.
- **Reactive Shopping Cart**:
  - Instant quantity updates (`+` / `-`) and item removal.
  - Promo code verification system (e.g., `FALL20` for 20% discount).
  - Accurate breakdown: Subtotal, Delivery Fee, Tax (7.2%), Discount, and Grand Total.
- **Google Maps & Geolocation**:
  - Interactive **Google Maps** (`google_maps_flutter`) for delivery location picking.
  - Real-time device GPS location via `geolocator`.
  - Reverse geocoding via `geocoding` translating GPS coordinates into formatted street addresses.
  - Saved address book with default address selection.
- **Payment & Checkout**:
  - Multiple payment choices: **Cash on Delivery (COD)** and **ABA PayWay**.
  - ABA PayWay integration: KHQR generation, deep-linking into ABA Mobile app via Android MethodChannels, in-app WebView fallback, and background status polling.
  - Automatic currency conversion between USD and KHR (Cambodian Riel @ 4,100 rate).
- **Order Tracking**:
  - Chronological orders list with status badges: `Pending`, `Processing`, `Shipped`, `Delivered`, `Cancelled`.
  - Detailed receipt breakdown with product snapshots, recipient details, and payment statuses.
- **Wishlist**:
  - Local SharedPreferences caching for offline availability + background API sync.
  - Direct "Add to Cart" action from the wishlist.
- **Profile & Multi-Language**:
  - User details, avatar, and contact information.
  - Language switcher supporting 6 languages with persistent storage.
  - Role switcher bottom sheet enabling authorized users to toggle into Admin mode.

---

### 2. Admin Control Tower

Protected by `RouteGuards.isAdmin` to prevent unauthorized customer access:

- **Dashboard**: Live analytics of sales, order volumes, inventory, and active categories.
- **Category Management**: Full CRUD operations for product categories with custom slug and icon support.
- **Product Catalog Management**: Comprehensive product creation and update flow, multi-image upload, variant management (sizes, colors, SKUs), and pricing.
- **Promotional Banners**: Add, update, and reorder storefront banners.
- **Order Fulfillment**: Track customer orders, inspect item details, and transition order fulfillment stages (`Pending` ➔ `Processing` ➔ `Shipped` ➔ `Delivered` ➔ `Cancelled`).

---

## ⚡ Riverpod State Management Architecture

The project leverages Riverpod 2.x features:

```dart
// 1. Immutable State Class
class CartState {
  final AsyncValue<CartRes> cart;
  final bool isPromoApplied;
  final String promoCode;
  final double promoDiscountPercent;

  const CartState({
    this.cart = const AsyncValue.loading(),
    this.isPromoApplied = true,
    this.promoCode = 'FALL20',
    this.promoDiscountPercent = 0.20,
  });

  CartState copyWith({...}) => CartState(...);
}

// 2. Notifier Controller
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    loadCart();
    return const CartState();
  }

  Future<void> addToCart(int productId, {int quantity = 1, int? variantId}) async {
    // Business logic & API dispatch
  }
}

// 3. Provider Definition
final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
```

### Key Providers Across the Project:

| Provider                            | Type                                                 | Description                                  |
| :---------------------------------- | :--------------------------------------------------- | :------------------------------------------- |
| `appLanguageProvider`               | `NotifierProvider<AppLanguageNotifier, AppLanguage>` | Current active locale & language switcher    |
| `activeRoleProvider`                | `NotifierProvider<ActiveRoleNotifier, UserRole>`     | Current active role (`customer` vs `admin`)  |
| `storageServiceProvider`            | `Provider<StorageService>`                           | Shared preferences singleton dependency      |
| `dioProvider` / `apiClientProvider` | `Provider<ApiClient>`                                | Configured Dio HTTP client                   |
| `mainPageNotifierProvider`          | `NotifierProvider<MainPageNotifier, int>`            | Bottom navigation shell index                |
| `homeNotifierProvider`              | `NotifierProvider<HomeNotifier, HomeState>`          | Banners, categories, and product catalog     |
| `cartNotifierProvider`              | `NotifierProvider<CartNotifier, CartState>`          | Shopping bag items, quantities, promo codes  |
| `wishlistNotifierProvider`          | `NotifierProvider<WishlistNotifier, WishlistState>`  | Saved products & sync state                  |
| `ordersNotifierProvider`            | `NotifierProvider<OrdersNotifier, OrdersState>`      | Order history & status filters               |
| `adminNotifierProvider`             | `NotifierProvider<AdminNotifier, AdminState>`        | Admin catalog, categories & order management |

---

## 🛠️ Tech Stack & Dependencies

| Category                | Technology / Package                                                                          | Purpose                                      |
| :---------------------- | :-------------------------------------------------------------------------------------------- | :------------------------------------------- |
| **Framework**           | [Flutter](https://flutter.dev) `^3.10.4`                                                      | Cross-platform UI toolkit                    |
| **Language**            | [Dart](https://dart.dev) `^3.10.4`                                                            | Modern object-oriented programming language  |
| **State Management**    | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) `^2.6.1`                        | Reactive, compile-time safe state management |
| **Networking**          | [dio](https://pub.dev/packages/dio) `^5.11.0`                                                 | HTTP client with token interceptors          |
| **Local Storage**       | [shared_preferences](https://pub.dev/packages/shared_preferences) `^2.5.5`                    | Key-value store & offline caching            |
| **Environment**         | [flutter_flavor](https://pub.dev/packages/flutter_flavor) `^3.1.4`                            | Build flavor environments                    |
| **Push Notifications**  | [firebase_messaging](https://pub.dev/packages/firebase_messaging) `^16.5.0`                   | FCM push notifications                       |
| **Local Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) `^22.3.0` | Local notification banners                   |
| **Firebase**            | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`                       | Firebase cloud ecosystem                     |
| **Maps & Location**     | `google_maps_flutter`, `geolocator`, `geocoding`                                              | Map location picker, GPS, and geocoding      |
| **Payment Gateway**     | `dart_payway` `^1.1.0+2`, `qr_flutter` `^4.1.0`                                               | ABA PayWay, KHQR generator & deep links      |
| **Web & Launchers**     | `webview_flutter` `^4.14.1`, `url_launcher` `^6.3.2`                                          | In-app browser & external app intents        |
| **UI Polish**           | `google_fonts`, `carousel_slider`, `shimmer`, `cached_network_image`, `flutter_svg`, `badges` | Modern aesthetics and micro-animations       |

---

## 📂 Project Directory Structure

```
ecommerce_riverpod/
├── android/                        # Android Kotlin DSL project setup
├── assets/                         # SVG icons, logos, and payment badges
│   └── icons/
├── ios/                            # iOS native CocoaPods setup
├── lib/
│   ├── app/
│   │   ├── core/                   # Core infrastructure
│   │   │   ├── config/             # Build-time env & flavor configuration
│   │   │   ├── constants/          # API endpoints, assets, icons, constants
│   │   │   ├── error/              # Failure & exception handling
│   │   │   ├── network/            # ApiClient with Dio interceptors
│   │   │   ├── providers/          # Global Riverpod core & storage providers
│   │   │   ├── router/             # AppRouter, RouteNames, RouteGuards
│   │   │   ├── services/           # StorageService, NotificationService
│   │   │   ├── theme/              # AppTheme, AppColors, AppFonts
│   │   │   ├── utils/              # MediaUrlResolver, l10n extensions
│   │   │   └── widgets/            # Reusable UI widgets
│   │   └── data/                   # Shared data access layer
│   │       ├── models/             # Product, Order, User, Cart, Category models
│   │       ├── providers/          # Remote HTTP data providers
│   │       └── repository/         # Repositories uniting providers & storage
│   ├── features/                   # Domain features (Clean Architecture)
│   │   ├── address/                # Google Maps address picker & forms
│   │   ├── admin/                  # Admin dashboard, products, categories, orders
│   │   ├── auth/                   # Login, register, email verification
│   │   ├── cart/                   # Shopping bag & promo codes
│   │   ├── checkout/               # Order placement & payment method selection
│   │   ├── home/                   # Catalog, banners, search & filters
│   │   ├── language/               # Language selection view
│   │   ├── main_page/              # Floating navigation shell (IndexedStack)
│   │   ├── notification/           # Notification center
│   │   ├── orders/                 # Customer order tracking & details
│   │   ├── payment/                # ABA PayWay integration (KHQR, polling, webview)
│   │   ├── product_detail/         # Variant selection, image gallery, specs
│   │   ├── profile/                # User account & role switching
│   │   ├── splash/                 # Startup splash screen
│   │   └── wishlist/               # Cached wishlist & favorites
│   ├── l10n/                       # Localization ARB files
│   ├── app.dart                    # ConsumerWidget root MaterialApp
│   ├── firebase_options_dev.dart   # Dev Firebase config
│   ├── firebase_options_staging.dart # Staging Firebase config
│   ├── firebase_options_prod.dart  # Prod Firebase config
│   ├── flavor.dart                 # Active flavor resolver
│   └── main.dart                   # ProviderScope initialization & app entry
├── .env.example                    # Environment template
├── flavorizr.yaml                  # Flavorizr configuration
├── pubspec.yaml                    # Riverpod dependencies & assets
└── README.md                       # Project documentation
```

---

## 🚦 Navigation & Route Guards

Navigation is decoupled and handled cleanly by `AppRouter` and `RouteGuards`:

```dart
MaterialApp(
  navigatorKey: AppRouter.navigatorKey,
  onGenerateRoute: AppRouter.onGenerateRoute,
  initialRoute: RouteNames.splash,
  ...
);
```

### Route Guard Enforcement:

1. **Guest Guards**: If an authenticated user attempts to visit `/login` or `/register`, they are redirected to `/shell` (or `/admin` if holding an admin role).
2. **Auth Guards**: Protected customer routes (`/checkout`, `/orders`, `/profile`, `/addresses`, `/wishlist`) automatically redirect to `/login` if no valid token exists.
3. **Admin Guards**: Routes under `/admin` require both active authentication and admin role permissions; unauthorized accounts are redirected to `/shell`.

---

## 🏷️ Multi-Flavor Setup

| Flavor        | Android Application ID                  | iOS Bundle ID                           | Default Base URL               | Banner Color |
| :------------ | :-------------------------------------- | :-------------------------------------- | :----------------------------- | :----------- |
| **`dev`**     | `com.example.architecture_getx.dev`     | `com.example.architecture_getx.dev`     | `http://10.0.2.2:8000/api/v1`  | 🟢 Green     |
| **`staging`** | `com.example.architecture_getx.staging` | `com.example.architecture_getx.staging` | `http://10.0.2.2:8000/api/v1`  | 🟠 Orange    |
| **`prod`**    | `com.example.architecture_getx.prod`    | `com.example.architecture_getx.prod`    | `http://206.189.34.193/api/v1` | 🔴 Red       |

---

## 🔐 Environment Configuration (.env)

Create a `.env` file in the root directory based on `.env.example`:

```properties
APP_ENV=production
API_BASE_URL_DEV=http://10.0.2.2:8000/api/v1
API_BASE_URL_STAGING=http://your-staging-server/api/v1
API_BASE_URL_PROD=http://your-production-server/api/v1

ABA_MERCHANT_NAME=Your Merchant Name
ABA_MERCHANT_API_KEY=your_merchant_api_key_here
ABA_MERCHANT_ID=your_merchant_id_here
ABA_BASE_URL=https://checkout-sandbox.payway.com.kh

ABA_REFERER_DOMAIN=https://your-domain.com
ABA_RETURN_URL=https://your-domain.com/aba-payway-return
```

---

## 🌐 Internationalization & Localization

Supports **6 languages** with dynamic font selection:

- **English (`en`)** ➔ Google Fonts **Inter**
- **Khmer (`km`)** ➔ Google Fonts **Battambang**
- **Japanese (`ja`)** ➔ Google Fonts **Inter**
- **Korean (`ko`)** ➔ Google Fonts **Inter**
- **Vietnamese (`vi`)** ➔ Google Fonts **Inter**
- **Chinese (`zh`)** ➔ Google Fonts **Inter**

The `appLanguageProvider` listens to user preferences, persists changes via `StorageService`, and updates the entire UI reactively without restarting the app.

---

## ⚙️ Core Infrastructure & Services

### Networking & Dio Client

- Interceptors handle bearer token injection dynamically based on the request type (User vs Admin).
- Automated 401 unauthenticated redirect clears cached session data and routes to login.
- Automated 403 role-retry logic refreshes admin credentials and re-executes blocked requests.

### Persistent Storage & Caching

- Key-value persistence using `shared_preferences`.
- Offline caching for wishlist, notification feed, search history, and default delivery address.

### Push & Local Notifications

- Integrates `firebase_messaging` with a top-level `firebaseBackgroundHandler`.
- Foreground banners displayed through `flutter_local_notifications` via a dedicated Android notification channel.
- Device FCM tokens are synchronized with `/device-tokens` on startup.

### ABA PayWay & KHQR Payment

- Real-time KHQR generation for cashless transactions.
- Deep-links to the native ABA Mobile banking app via Android MethodChannels.
- In-app fallback with `webview_flutter`.
- Transaction polling confirms payment completion and executes order creation.

---

## 🔗 API Integration Reference

| Method     | Endpoint                  | Description                                             |
| :--------- | :------------------------ | :------------------------------------------------------ |
| `POST`     | `/auth/login`             | Authenticate customer & return token                    |
| `POST`     | `/auth/register`          | Register new account                                    |
| `GET`      | `/auth/me`                | Fetch authenticated user profile                        |
| `GET`      | `/products`               | Retrieve catalog with pagination & filters              |
| `GET`      | `/categories`             | Fetch category listing                                  |
| `GET`      | `/banners`                | Fetch active homepage banners                           |
| `GET/POST` | `/cart` / `/cart/items`   | Manage customer cart items                              |
| `GET/POST` | `/orders`                 | Retrieve order history & submit orders                  |
| `GET/POST` | `/addresses`              | Fetch & save delivery addresses                         |
| `POST`     | `/payments/payway/create` | Initiate ABA PayWay transaction                         |
| `POST`     | `/payments/payway/status` | Verify PayWay payment status                            |
| `ALL`      | `/admin/*`                | Administrative endpoints (Products, Categories, Orders) |

---

## 🚀 Installation & Getting Started

### 1. Setup Environment

```bash
git clone <repository-url>
cd ecommerce_riverpod
cp .env.example .env
```

### 2. Install Packages

```bash
flutter pub get
```

### 3. Generate Localization

```bash
flutter gen-l10n
```

### 4. Run the App

#### Development Flavor:

```bash
flutter run --flavor dev -t lib/main.dart --dart-define-from-file=.env
```

#### Staging Flavor:

```bash
flutter run --flavor staging -t lib/main.dart --dart-define-from-file=.env
```

#### Production Flavor:

```bash
flutter run --flavor prod -t lib/main.dart --dart-define-from-file=.env
```

---

## ⚡ Useful Commands

### Code Analysis

```bash
dart analyze
```

### Build Production Android APK

```bash
flutter build apk --release --flavor prod -t lib/main.dart --dart-define-from-file=.env
```

### Build Production Android App Bundle (AAB)

```bash
flutter build appbundle --release --flavor prod -t lib/main.dart --dart-define-from-file=.env
```

### Build iOS Release

```bash
flutter build ipa --release --flavor prod -t lib/main.dart --dart-define-from-file=.env
```

---

## 📄 License

Proprietary software developed for the E-Commerce platform. All rights reserved.

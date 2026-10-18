# 🛍️ Architecture GetX — E-Commerce Mobile Application

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.10.4-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%5E3.10.4-0175C2.svg?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-GetX%20Clean%20Architecture-brightgreen.svg)](https://pub.dev/packages/get)
[![Backend](https://img.shields.io/badge/Backend-Laravel%2011%20REST%20API-red.svg?logo=laravel)](https://laravel.com)
[![Firebase](https://img.shields.io/badge/Firebase-FCM%20%7C%20Auth%20%7C%20Firestore-orange.svg?logo=firebase)](https://firebase.google.com)
[![Payment](<https://img.shields.io/badge/Payment-ABA%20PayWay%20(KHQR)-005F86.svg>)](https://www.ababank.com)
[![Localization](https://img.shields.io/badge/Languages-EN%20%7C%20KM%20%7C%20JA%20%7C%20KO%20%7C%20VI%20%7C%20ZH-purple.svg)](#-internationalization--localization)

A modern, production-grade **E-Commerce Mobile Application** built with **Flutter** and powered by **GetX Clean Architecture**. The application connects to a **Laravel 11 REST API** backend and features multi-flavor environments (`dev`, `staging`, `prod`), Firebase Cloud Messaging notifications, interactive Google Maps address selection, 6-language internationalization, ABA PayWay payment gateway integration with KHQR, and a full-featured **Admin Control Tower**.

---

## 📑 Table of Contents

- [Architectural Overview](#-architectural-overview)
- [Key Features](#-key-features)
  - [Customer Storefront](#1-customer-storefront)
  - [Admin Control Tower](#2-admin-control-tower)
- [Tech Stack & Dependencies](#-tech-stack--dependencies)
- [Project Directory Structure](#-project-directory-structure)
- [Multi-Flavor Setup](#-multi-flavor-setup)
- [Environment Configuration (.env)](#-environment-configuration-env)
- [Internationalization & Localization](#-internationalization--localization)
- [Core Architecture Details](#-core-architecture-details)
  - [Network Layer & Interceptors (Dio)](#network-layer--interceptors-dio)
  - [Local Storage & Caching (SharedPreferences)](#local-storage--caching-sharedpreferences)
  - [Push & Local Notifications (FCM)](#push--local-notifications-fcm)
  - [Payment Gateway (ABA PayWay & KHQR)](#payment-gateway-aba-payway--khqr)
  - [Route Management & Guards](#route-management--guards)
- [API Integration Overview](#-api-integration-overview)
- [Installation & Getting Started](#-installation--getting-started)
- [Useful Commands](#-useful-commands)
- [Companion Project: Riverpod Edition (ecommerce_riverpod)](#-companion-project-riverpod-edition-ecommerce_riverpod)

---

## 🏛️ Architectural Overview

The application follows the **GetX Pattern (Clean Layered Architecture)** ensuring high maintainability, testability, and separation of concerns:

```
┌────────────────────────────────────────────────────────────────┐
│                       Presentation Layer                       │
│     Modules (Views, Controllers, Custom Widgets, Bindings)      │
└───────────────────────────────┬────────────────────────────────┘
                                │
┌───────────────────────────────▼────────────────────────────────┐
│                          Core Layer                            │
│  Theme, Config, Constants, Middlewares, Services, Network      │
└───────────────────────────────┬────────────────────────────────┘
                                │
┌───────────────────────────────▼────────────────────────────────┐
│                       Data Access Layer                        │
│   Repositories (Business Logic Abstraction & Cache Strategy)   │
└───────────────────────────────┬────────────────────────────────┘
                                │
┌───────────────────────────────▼────────────────────────────────┐
│                      Data Source Layer                         │
│  Providers (Dio REST Client)  │  Local Storage (Prefs Cache)   │
└───────────────────────────────┴────────────────────────────────┘
```

1. **Presentation Layer (`lib/app/modules/`)**:
   - Organized strictly by feature domain (e.g., `auth`, `home`, `cart`, `orders`, `admin`).
   - UI views extend `GetView<T>` or `StatelessWidget`.
   - Reactive UI binding using `Obx(() => ...)` and `Rx` variables.
   - Declarative route-level dependency injection using `Bindings`.

2. **Core Layer (`lib/app/core/`)**:
   - Centralized network engine (`ApiClient`) wrapping `Dio` with authentication, error recovery, token injection, and retry policies.
   - Persistent device storage service (`StorageService`) with offline caching.
   - Push and local notification services (`NotificationService`).
   - Dynamic theming with automatic language font switching (Inter vs Battambang).

3. **Data Layer (`lib/app/data/`)**:
   - **Models**: Immutable data models with comprehensive `.fromJson()` / `.toJson()` mapping and safe fallback handling.
   - **Providers**: Network clients performing raw HTTP requests via `ApiClient`.
   - **Repositories**: Abstraction layer between data providers, local storage caches, and presentation controllers.

---

## ✨ Key Features

### 1. Customer Storefront

- **Splash & Dynamic Onboarding**: Fast application startup checking authentication token and routing users accordingly.
- **Modern Floating Navigation**: Custom frosted-glass navigation bar with backdrop blur and active badge counters for Cart and Wishlist.
- **Home & Catalog**:
  - Carousel hero banners with auto-scroll and indicators.
  - Horizontal Category chips with real-time filtering.
  - Dynamic product catalog displaying sale tags, stock status, ratings, and price calculations.
- **Advanced Product Search & Filter**:
  - Real-time search with recent search history caching.
  - Bottom sheet filter supporting price ranges, categories, customer ratings, and sort order.
- **Product Details**:
  - Multi-image zoomable preview gallery.
  - Variant selector (Size, Color, SKU).
  - Live stock check and low-inventory warnings.
  - One-tap add to Cart and Wishlist toggling.
- **Cart Management**:
  - Quantity adjustments (`+` / `-`) with immediate local and server synchronization.
  - Real-time subtotal, discounts, and estimated totals.
  - Swipe-to-remove and empty cart states.
- **Interactive Address Book & Geolocation**:
  - Integrated **Google Maps** (`google_maps_flutter`).
  - GPS auto-location via `geolocator`.
  - Reverse geocoding via `geocoding` (converting coordinates to street addresses).
  - Saved addresses with default address flag.
- **Payment & Checkout**:
  - Multiple payment methods: **Cash on Delivery (COD)** and **ABA PayWay**.
  - Integrated ABA PayWay checkout: KHQR display, deep-linking into ABA Mobile app, in-app WebView fallback, and automatic status polling.
  - Currency conversion between USD and KHR (Cambodian Riel @ 4,100 rate).
- **Order Management & Tracking**:
  - Real-time order status tracking with colored chips: `Pending`, `Processing`, `Shipped`, `Delivered`, `Cancelled`.
  - Detailed invoice view with product snapshots, pricing, delivery destination, and payment breakdown.
- **Wishlist & Favorites**:
  - Offline-first cached wishlist with instant UI toggling and background API synchronization.
- **User Profile & Settings**:
  - Profile details, avatar, and contact information.
  - Multi-language switcher (6 languages).
  - Fast role-switching bottom sheet for accounts with administrative privileges.

---

### 2. Admin Control Tower

Dedicated administrative console accessible by users with the `admin` role, protected by `AdminMiddleware`:

- **Dashboard Overview**: Metrics overview showing orders, revenue, inventory status, and active catalogs.
- **Category Management**:
  - Create, update, list, and delete categories.
  - Custom category slug and icon management.
- **Product Catalog Management**:
  - Full product creation and update wizard.
  - Multi-image upload and primary image selection.
  - Comprehensive variant configuration (size, color, SKU, price delta).
  - Stock and pricing control (regular price vs promotional sale price).
- **Promotional Banner Management**:
  - Manage homepage hero banners, links, and display order.
- **Order Fulfillment & Status Updates**:
  - Order search and inspection.
  - One-touch status transitions: `Pending` ➔ `Processing` ➔ `Shipped` ➔ `Delivered` ➔ `Cancelled`.

---

## 🛠️ Tech Stack & Dependencies

| Category                | Technology / Package                                                                                                                                                                                | Purpose                                     |
| :---------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------ |
| **Framework**           | [Flutter](https://flutter.dev) `^3.10.4`                                                                                                                                                            | Cross-platform UI toolkit                   |
| **Language**            | [Dart](https://dart.dev) `^3.10.4`                                                                                                                                                                  | Modern object-oriented programming language |
| **State Management**    | [get](https://pub.dev/packages/get) `^4.7.3`                                                                                                                                                        | Reactive state management, DI & routing     |
| **HTTP & Networking**   | [dio](https://pub.dev/packages/dio) `^5.11.0`                                                                                                                                                       | Powerful HTTP client with interceptors      |
| **Local Storage**       | [shared_preferences](https://pub.dev/packages/shared_preferences) `^2.5.5`                                                                                                                          | Persistent key-value storage & cache        |
| **Environment**         | [flutter_flavor](https://pub.dev/packages/flutter_flavor) `^3.1.4`                                                                                                                                  | Flavor environment management               |
| **Push Notifications**  | [firebase_messaging](https://pub.dev/packages/firebase_messaging) `^16.5.0`                                                                                                                         | FCM cloud push notifications                |
| **Local Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) `^22.3.0`                                                                                                       | Device notification banner handling         |
| **Firebase Suite**      | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`                                                                                                                             | Firebase backend ecosystem                  |
| **Maps & Location**     | [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) `^2.6.0`, [geolocator](https://pub.dev/packages/geolocator) `^13.0.1`, [geocoding](https://pub.dev/packages/geocoding) `^3.0.0` | Interactive maps, GPS & reverse geocoding   |
| **Payment Gateway**     | [dart_payway](https://pub.dev/packages/dart_payway) `^1.1.0+2`, [qr_flutter](https://pub.dev/packages/qr_flutter) `^4.1.0`                                                                          | ABA PayWay, KHQR generator & deep links     |
| **Web & Launchers**     | [webview_flutter](https://pub.dev/packages/webview_flutter) `^4.14.1`, [url_launcher](https://pub.dev/packages/url_launcher) `^6.3.2`                                                               | In-app web views & external app launchers   |
| **UI Components**       | `google_fonts`, `carousel_slider`, `shimmer`, `cached_network_image`, `flutter_svg`, `smooth_page_indicator`, `flutter_rating_bar`, `badges`                                                        | Polished, modern UI/UX design               |

---

## 📂 Project Directory Structure

```
architecture_getx/
├── android/                        # Android native configuration (Kotlin DSL, Gradle 8.x)
├── assets/                         # Static assets (PNG, JPG, SVG icons & logos)
│   └── icons/
├── ios/                            # iOS native project and CocoaPods config
├── lib/
│   ├── app/
│   │   ├── bindings/               # Global initial dependency bindings
│   │   │   └── init_bindings.dart  # Pre-registers ApiClient, Repositories, Providers
│   │   ├── core/                   # Application foundation
│   │   │   ├── config/             # Build-time environment config (EnvConfig)
│   │   │   ├── constants/          # API endpoints, assets, icons, constants
│   │   │   ├── middleware/         # Auth, Guest, and Admin route middlewares
│   │   │   ├── network/            # Dio ApiClient with token interceptors & error handlers
│   │   │   ├── services/           # StorageService, NotificationService
│   │   │   ├── theme/              # AppTheme, AppColors, dynamic AppFonts
│   │   │   ├── utils/              # MediaUrlResolver, l10n extensions
│   │   │   └── widgets/            # Generic components (Loading, EmptyState, RoleSwitch)
│   │   ├── data/                   # Data layer
│   │   │   ├── models/             # Product, Order, User, Cart, Category, Address models
│   │   │   ├── providers/          # Dio-based remote API providers
│   │   │   └── repository/         # Data repositories uniting providers & cache
│   │   ├── modules/                # Feature-based presentation modules
│   │   │   ├── aba_payway/         # ABA PayWay integration (KHQR, polling, webview)
│   │   │   ├── address/            # Google Map location picker & address form
│   │   │   ├── admin/              # Store management (Products, Categories, Orders)
│   │   │   ├── auth/               # Login & Register views and controllers
│   │   │   ├── cart/               # Cart list, quantity, checkout trigger
│   │   │   ├── checkout/           # Delivery address & payment method selection
│   │   │   ├── home/               # Product catalog, banner carousel, search & filter
│   │   │   ├── language/           # Language selection view
│   │   │   ├── main_page/          # Floating bottom navigation shell
│   │   │   ├── notification/       # Notification center
│   │   │   ├── order_success/      # Post-checkout celebration screen
│   │   │   ├── orders/             # Customer order history & detail tracking
│   │   │   ├── product_detail/     # Product specs, variants, image gallery
│   │   │   ├── profile/            # User account settings & role switch
│   │   │   ├── splash_screen/      # Initial loading & route dispatcher
│   │   │   └── wishlist/           # Cached wishlist & quick cart transfer
│   │   └── routes/                 # Named routes & GetPage definitions
│   │       ├── app_pages.dart      # Route list with bindings and middlewares
│   │       └── app_routes.dart     # String route constants
│   ├── l10n/                       # Localization ARB files & generated classes
│   │   ├── app_en.arb              # English
│   │   ├── app_km.arb              # Khmer (with Battambang font)
│   │   ├── app_ja.arb              # Japanese
│   │   ├── app_ko.arb              # Korean
│   │   ├── app_vi.arb              # Vietnamese
│   │   └── app_zh.arb              # Chinese
│   ├── app.dart                    # Main GetMaterialApp & flavor banner overlay
│   ├── firebase_options_dev.dart   # Dev Firebase configuration
│   ├── firebase_options_staging.dart # Staging Firebase configuration
│   ├── firebase_options_prod.dart  # Production Firebase configuration
│   ├── flavor.dart                 # Flavor resolver (dev, staging, prod)
│   └── main.dart                   # Application entrypoint
├── packages/                       # Embedded package patches
│   └── get/                        # Pinned GetX patch resolving snackbar animation race
├── .env.example                    # Template for environment credentials
├── flavorizr.yaml                  # Flavorizr configuration file
├── pubspec.yaml                    # Project dependencies and asset declarations
└── README.md                       # Project documentation
```

---

## 🏷️ Multi-Flavor Setup

The application supports 3 distinct build flavors: `dev`, `staging`, and `prod`. Each flavor is configured with isolated application IDs, bundle identifiers, backend endpoints, and Firebase credentials:

| Flavor        | Android Application ID                  | iOS Bundle ID                           | Default Base URL               | Banner Color |
| :------------ | :-------------------------------------- | :-------------------------------------- | :----------------------------- | :----------- |
| **`dev`**     | `com.example.architecture_getx.dev`     | `com.example.architecture_getx.dev`     | `http://10.0.2.2:8000/api/v1`  | 🟢 Green     |
| **`staging`** | `com.example.architecture_getx.staging` | `com.example.architecture_getx.staging` | `http://10.0.2.2:8000/api/v1`  | 🟠 Orange    |
| **`prod`**    | `com.example.architecture_getx.prod`    | `com.example.architecture_getx.prod`    | `http://206.189.34.193/api/v1` | 🔴 Red       |

The active flavor displays a diagnostic ribbon banner at the top-left corner during execution for quick visual confirmation.

---

## 🔐 Environment Configuration (.env)

Configuration values are injected at build or run time via `--dart-define-from-file=.env`.

Create a `.env` file in the root directory based on `.env.example`:

# App Environment (development, staging, production)

APP_ENV=production

# API Base URLs

API_BASE_URL_DEV=http://10.0.2.2:8000/api/v1
API_BASE_URL_STAGING=http://your-staging-server/api/v1
API_BASE_URL_PROD=http://your-production-server/api/v1

# ABA PayWay Credentials (Sandbox / Production)

ABA_MERCHANT_NAME=Your Merchant Name
ABA_MERCHANT_API_KEY=your_merchant_api_key_here
ABA_MERCHANT_ID=your_merchant_id_here
ABA_BASE_URL=https://checkout-sandbox.payway.com.kh

# Return URLs for Payment Completion

ABA_REFERER_DOMAIN=https://your-domain.com
ABA_RETURN_URL=https://your-domain.com/aba-payway-return

---

## 🌐 Internationalization & Localization

The application features complete end-to-end localization supporting **6 languages**:

| Code | Language                | Default Typography         |
| :--- | :---------------------- | :------------------------- |
| `en` | English                 | Google Fonts**Inter**      |
| `km` | Khmer (ភាសាខ្មែរ)       | Google Fonts**Battambang** |
| `ja` | Japanese (日本語)       | Google Fonts**Inter**      |
| `ko` | Korean (한국어)         | Google Fonts**Inter**      |
| `vi` | Vietnamese (Tiếng Việt) | Google Fonts**Inter**      |
| `zh` | Chinese (中文)          | Google Fonts**Inter**      |

- **Dynamic Typography Switching**: When the Khmer (`km`) locale is activated, the theme typography seamlessly switches to Google Fonts **Battambang** with optimized line heights and letter spacing.
- **Context Extension**: Use `context.l10n.<key>` anywhere in the UI for clean, type-safe translations.
- **Persistence**: Selected language choice is saved permanently via `StorageService` and restored on app launch.

---

## ⚙️ Core Architecture Details

### Network Layer & Interceptors (Dio)

Located in [`lib/app/core/network/api_client.dart`](lib/app/core/network/api_client.dart):

- **Relative Path Resolution**: Normalizes paths and connects to the active flavor's base URL.
- **Smart Token Injection**: Automatically determines whether a request targets customer endpoints or administrative endpoints (`/admin/`) and injects the corresponding bearer token (`userToken` vs `adminToken`).
- **Automated 401 Session Expiry**: Flushes credentials and smoothly navigates the user back to the login screen upon session expiry.
- **Automated 403 Role Recovery**: Automatically retries admin operations with fresh admin tokens if role validation errors occur.

### Local Storage & Caching (SharedPreferences)

Located in [`lib/app/core/services/storage_service.dart`](lib/app/core/services/storage_service.dart):

- Manages authentication tokens, admin tokens, and active user profile objects.
- Caches local wishlists and notifications for instant offline responsiveness.
- Persists recent search queries and address selection preferences.

### Push & Local Notifications (FCM)

Located in [`lib/app/core/services/notification_service.dart`](lib/app/core/services/notification_service.dart):

- Firebase Cloud Messaging integration for foreground and background message handling (`firebaseBackgroundHandler`).
- Android notification channels with high-importance priority banners.
- Automatic registration of device FCM tokens with the backend API (`/device-tokens`).

### Payment Gateway (ABA PayWay & KHQR)

Located in [`lib/app/modules/aba_payway/`](lib/app/modules/aba_payway/):

- Prepares transactions via `dart_payway`.
- Generates KHQR for instant scan-and-pay across Cambodian banking apps.
- Dispatches deep links into the native **ABA Mobile** banking application via custom Android MethodChannels.
- Embeds in-app `webview_flutter` fallback.
- Background polling loop periodically checks transaction verification endpoints and confirms order generation upon payment capture.

### Route Management & Guards

Located in [`lib/app/core/middleware/auth_middleware.dart`](lib/app/core/middleware/auth_middleware.dart):

- **`AuthMiddleware`**: Guards protected customer routes (Cart, Profile, Orders, Checkout). Redirects unauthenticated users to `/login`.
- **`GuestMiddleware`**: Guards guest routes (`/login`, `/register`). Redirects already authenticated users to `/shell`.
- **`AdminMiddleware`**: Verifies both authentication status and `admin` role privileges. Non-admin users are safely redirected to the customer storefront.

---

## 🔗 API Integration Overview

The application communicates with a **Laravel 11 REST API** implementing standard RESTful conventions:

| Domain         | Method     | Endpoint                  | Description                            |
| :------------- | :--------- | :------------------------ | :------------------------------------- |
| **Auth**       | `POST`     | `/auth/login`             | User authentication & token delivery   |
| **Auth**       | `POST`     | `/auth/register`          | New customer registration              |
| **Auth**       | `GET`      | `/auth/me`                | Fetch authenticated profile details    |
| **Auth**       | `POST`     | `/auth/logout`            | Terminate session & revoke token       |
| **Products**   | `GET`      | `/products`               | Fetch paginated product catalog        |
| **Products**   | `GET`      | `/products/{id}`          | Fetch individual product with variants |
| **Categories** | `GET`      | `/categories`             | Fetch store categories                 |
| **Banners**    | `GET`      | `/banners`                | Fetch active promotional banners       |
| **Cart**       | `GET`      | `/cart`                   | Fetch current customer cart            |
| **Cart**       | `POST`     | `/cart/items`             | Add or update item quantity            |
| **Orders**     | `GET`      | `/orders`                 | Retrieve user order history            |
| **Orders**     | `POST`     | `/orders`                 | Submit new customer order              |
| **Addresses**  | `GET`      | `/addresses`              | Fetch saved delivery addresses         |
| **Addresses**  | `POST`     | `/addresses`              | Save new delivery address              |
| **Payments**   | `POST`     | `/payments/payway/create` | Initialize ABA PayWay transaction      |
| **Payments**   | `POST`     | `/payments/payway/status` | Verify PayWay payment status           |
| **Admin**      | `GET/POST` | `/admin/products`         | Manage products (Admin only)           |
| **Admin**      | `GET/POST` | `/admin/categories`       | Manage categories (Admin only)         |
| **Admin**      | `GET/PUT`  | `/admin/orders`           | Manage customer orders & statuses      |

---

## 🚀 Installation & Getting Started

### Prerequisites

Ensure you have the following installed on your machine:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.10.4`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.10.4`)
- [Android Studio](https://developer.android.com/studio) / Xcode (for iOS)
- Java 17+ (JDK 17 recommended for Gradle 8.x)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd architecture_getx
```

### 2. Configure Environment (.env)

Copy the example environment configuration and supply your API endpoints and credentials:

```bash
cp .env.example .env
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run Code Generation (if modifying models / localization)

```bash
# Generate localization files
flutter gen-l10n

# Run build runner (if using generated code)
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run the Application

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

### Static Analysis & Lints

```bash
dart analyze
```

### Build Release Android APK (Production)

```bash
flutter build apk --release --flavor prod -t lib/main.dart --dart-define-from-file=.env
```

### Build Android App Bundle (AAB for Google Play Store)

```bash
flutter build appbundle --release --flavor prod -t lib/main.dart --dart-define-from-file=.env
```

### Build iOS Release

```bash
flutter build ipa --release --flavor prod -t lib/main.dart --dart-define-from-file=.env
```

---

## 🔄 Companion Project: Riverpod Edition (`ecommerce_riverpod`)

Alongside this GetX architecture, this repository contains a twin implementation built with **Flutter Riverpod**: [`../ecommerce_riverpod`](file:///d:/Flutter%20Code/Avance_Flutter/E-commerce-mobile-app/ecommerce_riverpod/README.md).

Both projects share the identical **Laravel 11 REST API**, **Firebase Core & FCM**, **Google Maps**, and **ABA PayWay (KHQR)** payment engine, but showcase fundamentally different architectural paradigms:

### 📊 Architectural Comparison: GetX vs. Riverpod

| Architectural Aspect | `architecture_getx` (This Project) | `ecommerce_riverpod` (Companion Project) |
| :--- | :--- | :--- |
| **State Management** | GetX Reactive (`Rx<T>`, `obs`, `Obx(() => ...)`, `GetxController`) | Riverpod 2.x (`NotifierProvider`, `AsyncNotifierProvider`, `ref.watch()`, `ref.read()`) |
| **State Model** | Mutable observable values with automatic proxy listeners | Immutable state objects (`copyWith`) and typed `AsyncValue<T>` |
| **Dependency Injection** | Runtime Service Locator (`Get.put()`, `Get.lazyPut()`, `Get.find<T>()`) | Compile-time safe functional providers (`Provider<T>`, `ProviderScope(overrides: [...])`) |
| **Routing & Navigation** | `GetMaterialApp` + `GetPage` with GetX Middlewares (`Get.toNamed()`, `Get.offAllNamed()`) | Pure Flutter `MaterialApp` with `AppRouter` (`onGenerateRoute`), `RouteNames`, and `RouteGuards` |
| **Code Organization** | **Layered GetX Pattern**: `lib/app/{bindings, core, data, modules, routes}` | **Clean + Feature-First (DDD)**: `lib/features/{data, domain, presentation}` |
| **UI Base Widgets** | `GetView<T>` & `StatelessWidget` | `ConsumerWidget` & `ConsumerStatefulWidget` |
| **Shell Navigation** | Custom floating navigation bar switching `controller.screens[index]` | Frosted-glass navigation bar preserving tab state via `IndexedStack` |
| **Testing Isolation** | Requires `Get.reset()` and registering test mock controllers | Pure DI via `ProviderScope(overrides: [storageServiceProvider.overrideWithValue(...)])` |

### 📁 Riverpod Directory Layout (`ecommerce_riverpod`)

```
ecommerce_riverpod/lib/
├── app/
│   ├── core/
│   │   ├── config/             # Build-time env & flavor management
│   │   ├── constants/          # API endpoints, icons, assets, constants
│   │   ├── error/              # Failure & exception definitions
│   │   ├── network/            # ApiClient with Dio interceptors
│   │   ├── providers/          # Core & storage Riverpod providers
│   │   ├── router/             # AppRouter, RouteNames, and RouteGuards
│   │   ├── services/           # StorageService & NotificationService
│   │   ├── theme/              # AppTheme, AppColors, and dynamic AppFonts
│   │   └── widgets/            # Generic reusable widgets
│   └── data/                   # Shared data access layer
│       ├── models/             # Product, Order, User, Cart, Category models
│       ├── providers/          # Remote HTTP data providers
│       └── repository/         # Data repositories uniting providers & storage
└── features/                   # Clean Architecture feature modules
    ├── address/                # Google Maps address picker & forms
    ├── admin/                  # Admin dashboard, products, categories, orders
    ├── auth/                   # Login, register, email verification
    ├── cart/                   # Shopping bag & promo codes (FALL20)
    ├── checkout/               # Order placement & payment selection
    ├── home/                   # Catalog, banners, search & filters
    ├── language/               # Language selection view (6 languages)
    ├── main_page/              # Floating navigation shell (IndexedStack)
    ├── notification/           # Notification center & FCM handling
    ├── orders/                 # Customer order tracking & details
    ├── payment/                # ABA PayWay integration (KHQR, polling, webview)
    ├── product_detail/         # Variant selection, image gallery, specs
    ├── profile/                # User account & role switching
    ├── splash/                 # Startup splash screen & route dispatch
    └── wishlist/               # Cached wishlist & favorites
```

For the complete standalone documentation, setup instructions, and architecture guide of the Riverpod edition, see [ecommerce_riverpod/README.md](file:///d:/Flutter%20Code/Avance_Flutter/E-commerce-mobile-app/ecommerce_riverpod/README.md).

---

## 📄 License

This project is proprietary software developed for the E-Commerce platform. All rights reserved.

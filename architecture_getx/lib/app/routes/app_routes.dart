// ignore_for_file: constant_identifier_names
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const AUTH = _Paths.AUTH;
  static const LOGIN = _Paths.AUTH;
  static const REGISTER = _Paths.REGISTER;
  static const NOTIFICATION = _Paths.NOTIFICATION;
  static const SHELL = _Paths.SHELL;
  static const MAIN_PAGE = _Paths.SHELL;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
  static const CART = _Paths.CART;
  static const CHECKOUT = _Paths.CHECKOUT;
  static const ORDER_SUCCESS = _Paths.ORDER_SUCCESS;
  static const ORDERS = _Paths.ORDERS;
  static const ORDER_DETAIL = _Paths.ORDER_DETAIL;
  static const PROFILE = _Paths.PROFILE;
  static const ADDRESS_LIST = _Paths.ADDRESS_LIST;
  static const ADDRESS_FORM = _Paths.ADDRESS_FORM;
  static const SEARCH_PRODUCT = _Paths.SEARCH_PRODUCT;
  static const ADMIN_PAGE = _Paths.ADMIN;
  static const ADD_PRODUCT = _Paths.ADMIN_CREATE_PRODUCT;
  static const SPLASH_SCREEN = _Paths.SPLASH_SCREEN;
  static const WISHLIST = _Paths.WISHLIST;
  static const ABA_PAYWAY = _Paths.ABA_PAYWAY;
  static const LANGUAGE = _Paths.LANGUAGE;

  // ── Admin Routes ──
  static const ADMIN = _Paths.ADMIN;
  static const ADMIN_CREATE_CATEGORY = _Paths.ADMIN_CREATE_CATEGORY;
  static const ADMIN_UPDATE_CATEGORY = _Paths.ADMIN_UPDATE_CATEGORY;
  static const ADMIN_CREATE_PRODUCT = _Paths.ADMIN_CREATE_PRODUCT;
  static const ADMIN_UPDATE_PRODUCT = _Paths.ADMIN_UPDATE_PRODUCT;
  static const ADMIN_ADD_VARIANT = _Paths.ADMIN_ADD_VARIANT;
  static const ADMIN_ORDERS = _Paths.ADMIN_ORDERS;
  static const ADMIN_UPDATE_ORDER_STATUS = _Paths.ADMIN_UPDATE_ORDER_STATUS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const AUTH = '/login';
  static const REGISTER = '/register';
  static const NOTIFICATION = '/notification';
  static const SHELL = '/shell';
  static const PRODUCT_DETAIL = '/product-detail';
  static const CART = '/cart';
  static const CHECKOUT = '/checkout';
  static const ORDER_SUCCESS = '/order-success';
  static const ORDERS = '/orders';
  static const ORDER_DETAIL = '/order-detail';
  static const PROFILE = '/profile';
  static const ADDRESS_LIST = '/addresses';
  static const ADDRESS_FORM = '/address-form';
  static const SEARCH_PRODUCT = '/search-product';
  static const SPLASH_SCREEN = '/splash-screen';
  static const WISHLIST = '/wishlist';
  static const ABA_PAYWAY = '/aba-payway';
  static const LANGUAGE = '/language';

  // ── Admin Paths ──
  static const ADMIN = '/admin';
  static const ADMIN_CREATE_CATEGORY = '/admin/category/create';
  static const ADMIN_UPDATE_CATEGORY = '/admin/category/update';
  static const ADMIN_CREATE_PRODUCT = '/admin/product/create';
  static const ADMIN_UPDATE_PRODUCT = '/admin/product/update';
  static const ADMIN_ADD_VARIANT = '/admin/variant/add';
  static const ADMIN_ORDERS = '/admin/orders';
  static const ADMIN_UPDATE_ORDER_STATUS = '/admin/order/update-status';
}

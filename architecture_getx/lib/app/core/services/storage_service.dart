import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user.model.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _adminKey = 'is_admin';

  SharedPreferences? _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // save Token

  Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  String? getToken() => _prefs?.getString(_tokenKey);

  bool get hasToken {
    final t = getToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> removeToken() async {
    await _prefs?.remove(_tokenKey);
  }

  //  User

  Future<void> saveUser(UserModel user) async {
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final raw = _prefs?.getString(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  //  Admin flag

  Future<void> saveIsAdmin(bool value) async {
    await _prefs?.setBool(_adminKey, value);
  }

  bool get isAdmin => _prefs?.getBool(_adminKey) ?? false;

  //  Admin Token
  static const _adminTokenKey = 'admin_auth_token';

  Future<void> saveAdminToken(String token) async {
    await _prefs?.setString(_adminTokenKey, token);
  }

  String? getAdminToken() => _prefs?.getString(_adminTokenKey);

  Future<void> removeAdminToken() async {
    await _prefs?.remove(_adminTokenKey);
  }

  //  Active Role
  static const _activeRoleKey = 'active_role';

  Future<void> saveActiveRole(String role) async {
    await _prefs?.setString(_activeRoleKey, role);
  }

  String getActiveRole() {
    return _prefs?.getString(_activeRoleKey) ?? 'customer';
  }

  //  Wishlist cache
  static const _wishlistKey = 'local_wishlist_items';
  
  Future<void> saveWishlistRaw(List<String> rawList) async {
    await _prefs?.setStringList(_wishlistKey, rawList);
  }
  
  List<String> getWishlistRaw() {
    return _prefs?.getStringList(_wishlistKey) ?? [];
  }

  //  Notifications cache
  static const _notificationsKey = 'local_saved_notifications';

  Future<void> saveNotificationsRaw(List<String> rawList) async {
    await _prefs?.setStringList(_notificationsKey, rawList);
  }

  List<String> getNotificationsRaw() {
    return _prefs?.getStringList(_notificationsKey) ?? [];
  }

  // Recent Searches cache
  static const _recentSearchesKey = 'local_recent_searches';

  Future<void> saveRecentSearches(List<String> searches) async {
    await _prefs?.setStringList(_recentSearchesKey, searches);
  }

  List<String> getRecentSearches() {
    return _prefs?.getStringList(_recentSearchesKey) ?? [];
  }

  // Language
  static const _languageKey = 'app_language_code';

  Future<void> saveLanguage(String langCode) async {
    await _prefs?.setString(_languageKey, langCode);
  }

  String? getLanguage() => _prefs?.getString(_languageKey);

  // Address cache
  static const _defaultAddressIdKey = 'default_address_id';
  static const _localAddressesKey = 'local_saved_addresses';

  Future<void> saveDefaultAddressId(int id) async {
    await _prefs?.setInt(_defaultAddressIdKey, id);
  }

  int? getDefaultAddressId() => _prefs?.getInt(_defaultAddressIdKey);

  Future<void> saveLocalAddresses(List<String> rawAddresses) async {
    await _prefs?.setStringList(_localAddressesKey, rawAddresses);
  }

  List<String> getLocalAddresses() => _prefs?.getStringList(_localAddressesKey) ?? [];

  // clear

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.model.dart';
import '../constants/storage_constants.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Token
  Future<void> saveToken(String token) async {
    await _prefs?.setString(StorageConstants.authToken, token);
  }

  String? getToken() => _prefs?.getString(StorageConstants.authToken);

  bool get hasToken {
    final t = getToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> removeToken() async {
    await _prefs?.remove(StorageConstants.authToken);
  }

  // User
  Future<void> saveUser(UserModel user) async {
    await _prefs?.setString(StorageConstants.authUser, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final raw = _prefs?.getString(StorageConstants.authUser);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> removeUser() async {
    await _prefs?.remove(StorageConstants.authUser);
  }

  Future<void> clearAuth() async {
    await removeToken();
    await removeUser();
    await removeAdminToken();
  }

  // Admin flag
  Future<void> saveIsAdmin(bool value) async {
    await _prefs?.setBool(StorageConstants.isAdmin, value);
  }

  bool get isAdmin => _prefs?.getBool(StorageConstants.isAdmin) ?? false;

  // Admin Token
  Future<void> saveAdminToken(String token) async {
    await _prefs?.setString(StorageConstants.adminAuthToken, token);
  }

  String? getAdminToken() => _prefs?.getString(StorageConstants.adminAuthToken);

  Future<void> removeAdminToken() async {
    await _prefs?.remove(StorageConstants.adminAuthToken);
  }

  // Active Role
  Future<void> saveActiveRole(String role) async {
    await _prefs?.setString(StorageConstants.activeRole, role);
  }

  String getActiveRole() {
    return _prefs?.getString(StorageConstants.activeRole) ?? 'customer';
  }

  // Wishlist cache
  Future<void> saveWishlistRaw(List<String> rawList) async {
    await _prefs?.setStringList(StorageConstants.wishlistItems, rawList);
  }

  List<String> getWishlistRaw() {
    return _prefs?.getStringList(StorageConstants.wishlistItems) ?? [];
  }

  // Notifications cache
  Future<void> saveNotificationsRaw(List<String> rawList) async {
    await _prefs?.setStringList(StorageConstants.notifications, rawList);
  }

  List<String> getNotificationsRaw() {
    return _prefs?.getStringList(StorageConstants.notifications) ?? [];
  }

  // Recent Searches cache
  Future<void> saveRecentSearches(List<String> searches) async {
    await _prefs?.setStringList(StorageConstants.recentSearches, searches);
  }

  List<String> getRecentSearches() {
    return _prefs?.getStringList(StorageConstants.recentSearches) ?? [];
  }

  Future<void> clearRecentSearches() async {
    await _prefs?.remove(StorageConstants.recentSearches);
  }

  // Language
  Future<void> saveLanguage(String langCode) async {
    await _prefs?.setString(StorageConstants.languageCode, langCode);
  }

  String? getLanguage() => _prefs?.getString(StorageConstants.languageCode);

  // Address cache
  Future<void> saveDefaultAddressId(int id) async {
    await _prefs?.setInt(StorageConstants.defaultAddressId, id);
  }

  int? getDefaultAddressId() => _prefs?.getInt(StorageConstants.defaultAddressId);

  Future<void> saveLocalAddresses(List<String> rawAddresses) async {
    await _prefs?.setStringList(StorageConstants.localAddresses, rawAddresses);
  }

  List<String> getLocalAddresses() =>
      _prefs?.getStringList(StorageConstants.localAddresses) ?? [];

  // Clear
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}

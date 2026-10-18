import '../../../../app/core/services/storage_service.dart';
import '../../../../app/data/models/user.model.dart';


abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> saveUser(UserModel user);
  UserModel? getUser();
  Future<void> clearAuth();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveToken(String token) => _storage.saveToken(token);

  @override
  String? getToken() => _storage.getToken();

  @override
  Future<void> saveUser(UserModel user) => _storage.saveUser(user);

  @override
  UserModel? getUser() => _storage.getUser();

  @override
  Future<void> clearAuth() => _storage.clearAuth();
}

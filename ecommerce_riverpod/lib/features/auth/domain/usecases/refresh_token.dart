import '../../../../app/data/repository/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<dynamic> call() {
    return _repository.refreshToken();
  }
}

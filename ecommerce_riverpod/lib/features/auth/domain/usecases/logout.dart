import '../../../../app/data/repository/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<dynamic> call() {
    return _repository.logout();
  }
}

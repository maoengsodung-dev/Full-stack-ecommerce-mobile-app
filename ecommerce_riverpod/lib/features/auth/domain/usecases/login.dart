import '../../../../app/data/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<dynamic> call(String email, String password) {
    return _repository.login(email, password);
  }
}

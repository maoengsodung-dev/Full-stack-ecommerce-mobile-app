import '../../../../app/data/repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<dynamic> call({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}

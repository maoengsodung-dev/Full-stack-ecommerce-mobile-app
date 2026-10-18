import '../../../../app/data/models/user.model.dart';
import '../../../../app/data/repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<UserModel> call() {
    return _repository.getProfile();
  }
}

import '../../../../app/data/repository/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository _repository;

  RemoveFromCartUseCase(this._repository);

  Future<void> call(int itemId) {
    return _repository.removeItem(itemId);
  }
}

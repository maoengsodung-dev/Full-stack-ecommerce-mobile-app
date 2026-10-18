import '../../../../app/data/repository/cart_repository.dart';

class UpdateCartItemUseCase {
  final CartRepository _repository;

  UpdateCartItemUseCase(this._repository);

  Future<dynamic> call(int itemId, int quantity) {
    return _repository.updateItem(itemId, quantity);
  }
}

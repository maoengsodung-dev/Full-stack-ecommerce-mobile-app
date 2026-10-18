import '../../../../app/data/models/cart.model.dart';
import '../../../../app/data/repository/cart_repository.dart';

class GetCartUseCase {
  final CartRepository _repository;

  GetCartUseCase(this._repository);

  Future<CartRes> call() {
    return _repository.getCart();
  }
}

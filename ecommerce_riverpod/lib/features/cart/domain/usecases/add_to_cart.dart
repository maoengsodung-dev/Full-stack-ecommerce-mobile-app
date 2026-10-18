import '../../../../app/data/repository/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository _repository;

  AddToCartUseCase(this._repository);

  Future<dynamic> call(int productId, int quantity, {int? variantId}) {
    return _repository.addItem(productId, quantity, variantId: variantId);
  }
}

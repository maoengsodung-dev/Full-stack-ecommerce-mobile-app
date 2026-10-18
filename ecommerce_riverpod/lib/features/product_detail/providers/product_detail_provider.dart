import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data/models/product.model.dart';
import '../../../app/data/repository/product_repository.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';


class ProductDetailState {
  final AsyncValue<ProductRes> product;
  final int quantity;
  final int currentImageIndex;
  final String selectedColor;
  final String selectedSize;
  final ProductVariantModel? selectedVariant;
  final bool isFavorite;
  final bool isAddingToCart;
  final bool isDescriptionExpanded;

  const ProductDetailState({
    this.product = const AsyncValue.loading(),
    this.quantity = 1,
    this.currentImageIndex = 0,
    this.selectedColor = '',
    this.selectedSize = '',
    this.selectedVariant,
    this.isFavorite = false,
    this.isAddingToCart = false,
    this.isDescriptionExpanded = true,
  });

  ProductRes? get productData => product.valueOrNull;

  List<String> get availableSizes {
    final vSizes = productData?.variants
        .map((v) => v.size)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    if (vSizes != null && vSizes.isNotEmpty) return vSizes;
    return const [];
  }

  List<String> get availableColors {
    final vColors = productData?.variants
        .map((v) => v.color)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    if (vColors != null && vColors.isNotEmpty) return vColors;
    return const [];
  }

  List<ProductImageModel> get allImages {
    final p = productData;
    if (p == null) return const [];
    if (p.images.isNotEmpty) return p.images;
    if (p.primaryImage != null) {
      return [
        ProductImageModel(
          id: p.primaryImage!.id,
          url: p.primaryImage!.url,
          alt: p.primaryImage!.alt,
          isPrimary: true,
        ),
      ];
    }
    return const [];
  }

  double get currentPrice {
    final p = productData;
    if (p == null) return 0.0;
    if (selectedVariant != null && selectedVariant!.effectivePrice > 0) {
      return selectedVariant!.effectivePrice;
    }
    final base = p.effectivePrice > 0 ? p.effectivePrice : p.price;
    if (selectedVariant != null && selectedVariant!.priceOffset != 0) {
      return base + selectedVariant!.priceOffset;
    }
    return base;
  }

  int get currentStock {
    if (selectedVariant != null) return selectedVariant!.stock;
    return productData?.stock ?? 0;
  }

  ProductDetailState copyWith({
    AsyncValue<ProductRes>? product,
    int? quantity,
    int? currentImageIndex,
    String? selectedColor,
    String? selectedSize,
    ProductVariantModel? Function()? selectedVariant,
    bool? isFavorite,
    bool? isAddingToCart,
    bool? isDescriptionExpanded,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedVariant:
          selectedVariant != null ? selectedVariant() : this.selectedVariant,
      isFavorite: isFavorite ?? this.isFavorite,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isDescriptionExpanded:
          isDescriptionExpanded ?? this.isDescriptionExpanded,
    );
  }
}

class ProductDetailNotifier extends AutoDisposeFamilyNotifier<ProductDetailState, dynamic> {
  @override
  ProductDetailState build(dynamic arg) {
    if (arg is ProductRes) {
      Future.microtask(() {
        _setInitialProduct(arg);
        if (arg.slug.isNotEmpty) {
          _loadProduct(arg.slug);
        }
      });
      return ProductDetailState(product: AsyncValue.data(arg));
    } else if (arg != null) {
      Future.microtask(() => _loadProduct(arg));
      return const ProductDetailState();
    }
    return const ProductDetailState();
  }

  void _setInitialProduct(ProductRes p) {
    final wishlist = ref.read(wishlistNotifierProvider);
    final isFav = wishlist.isItemInWishlist(p.id);

    state = state.copyWith(
      product: AsyncValue.data(p),
      isFavorite: isFav,
    );
    _initVariantSelection(p);
  }

  Future<void> _loadProduct(dynamic idOrSlug) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      ProductRes p;
      if (idOrSlug is int) {
        p = await repo.getProductById(idOrSlug);
      } else {
        final parsedInt = int.tryParse(idOrSlug.toString());
        if (parsedInt != null) {
          p = await repo.getProductById(parsedInt);
        } else {
          p = await repo.getProductBySlug(idOrSlug.toString());
        }
      }
      _setInitialProduct(p);
    } catch (e, st) {
      if (state.product.valueOrNull == null) {
        state = state.copyWith(product: AsyncValue.error(e, st));
      }
    }
  }

  void _initVariantSelection(ProductRes p) {
    if (p.variants.isNotEmpty) {
      final v = p.variants.first;
      state = state.copyWith(
        selectedVariant: () => v,
        selectedColor: v.color ?? '',
        selectedSize: v.size ?? '',
      );
    }
  }

  void selectColor(String color) {
    state = state.copyWith(selectedColor: color);
    _resolveVariant();
  }

  void selectSize(String size) {
    state = state.copyWith(selectedSize: size);
    _resolveVariant();
  }

  void _resolveVariant() {
    final p = state.productData;
    if (p == null || p.variants.isEmpty) return;

    final matched = p.variants.where((v) {
      final matchC = state.selectedColor.isEmpty || v.color == state.selectedColor;
      final matchS = state.selectedSize.isEmpty || v.size == state.selectedSize;
      return matchC && matchS;
    }).firstOrNull;

    state = state.copyWith(selectedVariant: () => matched);
  }

  void setImageIndex(int index) {
    state = state.copyWith(currentImageIndex: index);
  }

  void setQuantity(int q) {
    if (q >= 1) state = state.copyWith(quantity: q);
  }

  void toggleDescription() {
    state = state.copyWith(
      isDescriptionExpanded: !state.isDescriptionExpanded,
    );
  }

  Future<void> toggleFavorite() async {
    final p = state.productData;
    if (p == null) return;
    await ref.read(wishlistNotifierProvider.notifier).toggleWishlist(p);
    final isFav = ref.read(wishlistNotifierProvider).isItemInWishlist(p.id);
    state = state.copyWith(isFavorite: isFav);
  }

  Future<bool> addToCart([BuildContext? context]) async {
    final p = state.productData;
    if (p == null) return false;

    state = state.copyWith(isAddingToCart: true);
    final success = await ref.read(cartNotifierProvider.notifier).addItem(
          p.id,
          quantity: state.quantity,
          product: p,
          variantId: state.selectedVariant?.id,
        );

    state = state.copyWith(isAddingToCart: false);

    if (success && context != null && context.mounted) {
      Navigator.of(context).pop();
    }

    return success;
  }
}

final productDetailProvider = NotifierProvider.autoDispose
    .family<ProductDetailNotifier, ProductDetailState, dynamic>(
  ProductDetailNotifier.new,
);

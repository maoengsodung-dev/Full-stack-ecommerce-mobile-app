import 'package:architecture_getx/app/data/models/product.model.dart';
import 'package:architecture_getx/app/data/repository/product_repository.dart';
import 'package:architecture_getx/app/modules/cart/controllers/cart_controller.dart';
import 'package:architecture_getx/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  final ProductRepository _repo;
  ProductDetailController(this._repo);

  final product = Rxn<ProductRes>();
  final quantity = 1.obs;
  final isLoading = false.obs;
  final currentImageIndex = 0.obs;
  final selectedColor = ''.obs;
  final selectedSize = ''.obs;
  final selectedVariant = Rxn<ProductVariantModel>();
  final isFavorite = false.obs;
  final isAddingToCart = false.obs;
  final isDescriptionExpanded = true.obs;
  late final PageController imagePageController;

  List<String> get availableSizes {
    final vSizes = product.value?.variants
        .map((v) => v.size)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    if (vSizes != null && vSizes.isNotEmpty) return vSizes;
    return const [];
  }

  List<String> get availableColors {
    final vColors = product.value?.variants
        .map((v) => v.color)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    if (vColors != null && vColors.isNotEmpty) return vColors;
    return const [];
  }

  List<ProductImageModel> get allImages {
    final p = product.value;
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
    final p = product.value;
    if (p == null) return 0.0;
    final variant = selectedVariant.value;
    if (variant != null && variant.effectivePrice > 0) {
      return variant.effectivePrice;
    }
    final base = p.effectivePrice > 0 ? p.effectivePrice : p.price;
    if (variant != null && variant.priceOffset != 0) {
      return base + variant.priceOffset;
    }
    return base;
  }

  int get currentStock {
    final variant = selectedVariant.value;
    if (variant != null) return variant.stock;
    return product.value?.stock ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    imagePageController = PageController();
    final args = Get.arguments;
    if (args is ProductRes) {
      product.value = args;
      _initVariantSelection();
      _checkFavoriteStatus();
      if (args.slug.isNotEmpty) {
        _loadProduct(args.slug);
      }
    } else if (args is String) {
      _loadProduct(args);
    } else if (args is int) {
      _loadProduct(args);
    }
  }

  @override
  void onClose() {
    imagePageController.dispose();
    super.onClose();
  }

  void selectImage(int index) {
    currentImageIndex.value = index;
    if (imagePageController.hasClients) {
      imagePageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void nextImage() {
    final images = allImages;
    if (images.isEmpty) return;
    final next = (currentImageIndex.value + 1) % images.length;
    selectImage(next);
  }

  void previousImage() {
    final images = allImages;
    if (images.isEmpty) return;
    final prev = (currentImageIndex.value - 1 + images.length) % images.length;
    selectImage(prev);
  }

  void _initVariantSelection() {
    final sizes = availableSizes;
    if (sizes.isNotEmpty && selectedSize.value.isEmpty) {
      selectedSize.value = sizes.contains('M') ? 'M' : sizes.first;
    }
    final colors = availableColors;
    if (colors.isNotEmpty && selectedColor.value.isEmpty) {
      selectedColor.value = colors.first;
    }
    _updateSelectedVariant();
  }

  void selectSize(String size) {
    selectedSize.value = size;
    _updateSelectedVariant();
  }

  void selectColor(String color) {
    selectedColor.value = color;
    _updateSelectedVariant();
  }

  void _updateSelectedVariant() {
    final variants = product.value?.variants ?? [];
    if (variants.isEmpty) {
      selectedVariant.value = null;
      return;
    }

    final match = variants.firstWhereOrNull((v) {
      final sizeMatches = selectedSize.value.isEmpty || v.size == selectedSize.value;
      final colorMatches = selectedColor.value.isEmpty || v.color == selectedColor.value;
      return sizeMatches && colorMatches;
    }) ?? variants.firstWhereOrNull((v) => v.size == selectedSize.value) ?? variants.firstOrNull;

    selectedVariant.value = match;
  }

  void _checkFavoriteStatus() {
    final p = product.value;
    if (p != null) {
      if (!Get.isRegistered<WishlistController>()) {
        Get.put(WishlistController(), permanent: true);
      }
      isFavorite.value = Get.find<WishlistController>().isItemInWishlist(p.id);
    }
  }

  Future<void> _loadProduct(dynamic slugOrId) async {
    try {
      isLoading.value = true;
      final loaded = slugOrId is String
          ? await _repo.getProductBySlug(slugOrId)
          : await _repo.getProductById(slugOrId);
      product.value = loaded;
      _initVariantSelection();
      _checkFavoriteStatus();
    } catch (e) {
      debugPrint('[ProductDetail] Error loading details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void increment() {
    final stock = currentStock > 0 ? currentStock : 99;
    if (quantity.value < stock) quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  Future<void> toggleFavorite() async {
    final p = product.value;
    if (p == null) return;

    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController(), permanent: true);
    }

    // Optimistic toggle
    isFavorite.value = !isFavorite.value;

    final wishlistCtrl = Get.find<WishlistController>();
    try {
      await wishlistCtrl.toggleWishlist(p, size: selectedSize.value);
    } catch (_) {
      isFavorite.value = wishlistCtrl.isItemInWishlist(p.id);
    }
  }

  Future<void> addToCart() async {
    final p = product.value;
    if (p == null || isAddingToCart.value) return;

    try {
      isAddingToCart.value = true;
      final success = await Get.find<CartController>().addItem(
        p.id,
        quantity: quantity.value,
        product: p,
        variantId: selectedVariant.value?.id,
      );

      if (success) {
        // Close screen product detail first
        Get.back();

        // Show success snackbar
        Get.snackbar(
          'Added to Cart',
          '${p.name} (x${quantity.value}) added to your cart',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('[ProductDetail] Error in addToCart: $e');
    } finally {
      isAddingToCart.value = false;
    }
  }

  Future<void> buyNow() async {
    final p = product.value;
    if (p == null || isAddingToCart.value) return;

    try {
      isAddingToCart.value = true;
      final success = await Get.find<CartController>().addItem(
        p.id,
        quantity: quantity.value,
        product: p,
        variantId: selectedVariant.value?.id,
      );
      if (success) {
        Get.toNamed(Routes.CHECKOUT);
      }
    } catch (e) {
      debugPrint('[ProductDetail] Error in buyNow: $e');
    } finally {
      isAddingToCart.value = false;
    }
  }
}

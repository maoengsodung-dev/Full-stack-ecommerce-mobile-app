import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:architecture_getx/app/routes/app_pages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../models/category_model.dart';
import '../../widgets/product_images_picker.dart';

class CreateProductView extends StatefulWidget {
  const CreateProductView({super.key});

  @override
  State<CreateProductView> createState() => _CreateProductViewState();
}

class _CreateProductViewState extends State<CreateProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _shortDescCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '10');
  ProductImagesData? _imagesData;

  int? _selectedCategoryId;
  String _status = 'active';
  bool _isFeatured = true;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<AdminController>();
    if (controller.categories.isNotEmpty) {
      _selectedCategoryId = controller.categories.first.id;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortDescCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _salePriceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AdminController controller) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      Get.snackbar(
        'Category Required',
        'Please select a category for this product.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final salePrice = _salePriceCtrl.text.trim().isNotEmpty
        ? double.tryParse(_salePriceCtrl.text.trim())
        : null;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    final primaryFile = _imagesData?.primaryFile;
    final localFiles = _imagesData?.sortedLocalFiles ?? const [];
    final existingUrls = _imagesData?.sortedExistingUrls ?? const [];

    final images = existingUrls.asMap().entries.map((e) {
      return {
        'url': e.value,
        'is_primary': primaryFile == null && e.key == 0,
      };
    }).toList();

    final success = await controller.createProduct(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      shortDescription: _shortDescCtrl.text.trim(),
      price: price,
      salePrice: salePrice,
      stock: stock,
      categoryId: _selectedCategoryId!,
      status: _status,
      isFeatured: _isFeatured,
      imageFile: primaryFile,
      imageFiles: localFiles,
      images: images,
    );

    if (success && mounted) {
      if (Get.key.currentState?.canPop() ?? false) {
        Get.key.currentState?.pop();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        if (Get.isSnackbarOpen) {
          Get.back();
        }
        if (mounted) {
          Get.back();
        }
        if (mounted) {
          Get.offNamed(Routes.ADMIN);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Create Product',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                _buildLabel('Product Name *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration('e.g. Sony WH-1000XM5'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter product name'
                      : null,
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                _buildLabel('Category *'),
                const SizedBox(height: 6),
                Obx(() {
                  final cats = controller.categories;
                  if (cats.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: const Text(
                        'No categories available. Please create a category first.',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 13,
                        ),
                      ),
                    );
                  }

                  if (_selectedCategoryId == null && cats.isNotEmpty) {
                    _selectedCategoryId = cats.first.id;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedCategoryId,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(14),
                        items: cats.map((AdminCategory cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategoryId = val);
                          }
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Short Description
                _buildLabel('Short Description *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _shortDescCtrl,
                  decoration: _inputDecoration('Catchy one-line description'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter short description'
                      : null,
                ),
                const SizedBox(height: 16),

                // Full Description
                _buildLabel('Detailed Description *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    'Full product specifications, details, and features...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter full description'
                      : null,
                ),
                const SizedBox(height: 16),

                // Pricing Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Regular Price (\$) *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration('99.99'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(v.trim()) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Sale Price (\$)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _salePriceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration('79.99'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stock & Status Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Stock Quantity *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('10'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(v.trim()) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Status'),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _status,
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(14),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'inactive',
                                    child: Text('Inactive'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'draft',
                                    child: Text('Draft'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _status = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Product Images
                ProductImagesPicker(
                  onChanged: (data) => _imagesData = data,
                ),
                const SizedBox(height: 16),

                // Featured Switch
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Featured Product',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: const Text(
                      'Highlight on store homepage and banners',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    value: _isFeatured,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _isFeatured = val),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                Obx(() {
                  final isBusy = controller.isSubmitting.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : () => _submit(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text(
                              'Publish Product',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}

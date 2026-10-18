import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../widgets/product_images_picker.dart';

class UpdateProductView extends StatefulWidget {
  const UpdateProductView({super.key});

  @override
  State<UpdateProductView> createState() => _UpdateProductViewState();
}

class _UpdateProductViewState extends State<UpdateProductView> {
  final _formKey = GlobalKey<FormState>();
  late AdminProduct _product;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _shortDescCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _salePriceCtrl;
  late final TextEditingController _stockCtrl;
  ProductImagesData? _imagesData;

  int? _selectedCategoryId;
  String _status = 'active';
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is AdminProduct) {
      _product = args;
    } else {
      _product = const AdminProduct(
        id: 0,
        name: '',
        slug: '',
        price: 0,
        stock: 0,
      );
    }

    _nameCtrl = TextEditingController(text: _product.name);
    _shortDescCtrl = TextEditingController(text: _product.shortDescription);
    _descCtrl = TextEditingController(text: _product.description);
    _priceCtrl = TextEditingController(text: _product.price.toStringAsFixed(2));
    _salePriceCtrl = TextEditingController(
      text: _product.salePrice != null ? _product.salePrice!.toStringAsFixed(2) : '',
    );
    _stockCtrl = TextEditingController(text: _product.stock.toString());
    _selectedCategoryId = _product.categoryId;
    _status = _product.status;
    _isFeatured = _product.isFeatured;
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

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final salePrice = _salePriceCtrl.text.trim().isNotEmpty
        ? double.tryParse(_salePriceCtrl.text.trim())
        : null;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    final updatePayload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'short_description': _shortDescCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': price,
      'sale_price': ?salePrice,
      'stock': stock,
      if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
      'status': _status,
      'is_featured': _isFeatured,
    };

    final primaryFile = _imagesData?.primaryFile;
    final localFiles = _imagesData?.sortedLocalFiles ?? const [];
    final existingUrls = _imagesData?.sortedExistingUrls;

    final success = await controller.updateProduct(
      _product.id,
      updatePayload,
      imageFile: primaryFile,
      imageFiles: localFiles,
      existingImageUrls: existingUrls,
    );
    if (success && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Edit Product #${_product.id}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
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
                _buildLabel('Product Name *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration('Product Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter product name' : null,
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                _buildLabel('Category *'),
                const SizedBox(height: 6),
                Obx(() {
                  final cats = controller.categories;
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
                          if (val != null) setState(() => _selectedCategoryId = val);
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
                  decoration: _inputDecoration('Short summary'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter short description' : null,
                ),
                const SizedBox(height: 16),

                // Full Description
                _buildLabel('Detailed Description *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: _inputDecoration('Detailed product description...'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                ),
                const SizedBox(height: 16),

                // Price Row
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration('0.00'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (double.tryParse(v.trim()) == null) return 'Invalid';
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration('Leave empty if none'),
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
                            decoration: _inputDecoration('0'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (int.tryParse(v.trim()) == null) return 'Invalid';
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
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _status,
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(14),
                                items: const [
                                  DropdownMenuItem(value: 'active', child: Text('Active')),
                                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
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
                  initialUrls: _product.imageUrls,
                  onChanged: (data) => _imagesData = data,
                ),
                const SizedBox(height: 16),

                // Featured Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Featured Product',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    subtitle: const Text(
                      'Highlight on homepage and top collections',
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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

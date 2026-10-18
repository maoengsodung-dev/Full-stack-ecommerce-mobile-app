import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../models/variant_model.dart';

class QuickColorItem {
  final String name;
  final Color color;

  const QuickColorItem({required this.name, required this.color});
}

class VariantForm extends StatefulWidget {
  final String initialSkuPrefix;
  final ValueChanged<AdminVariant>? onSubmit;
  final ValueChanged<List<AdminVariant>>? onSubmitMultiple;
  final bool isSubmitting;

  const VariantForm({
    super.key,
    this.initialSkuPrefix = '',
    this.onSubmit,
    this.onSubmitMultiple,
    this.isSubmitting = false,
  });

  @override
  State<VariantForm> createState() => _VariantFormState();
}

class _VariantFormState extends State<VariantForm> {
  late final TextEditingController _skuCtrl;
  final TextEditingController _sizeCtrl = TextEditingController(text: 'M');
  final TextEditingController _colorCtrl = TextEditingController(text: 'Black');
  final TextEditingController _offsetCtrl = TextEditingController(text: '0');
  final TextEditingController _stockCtrl = TextEditingController(text: '25');
  bool _isActive = true;
  bool _autoGenerateSku = true;
  bool _isMultiSize = false;
  bool _isMultiColor = false;

  final List<String> _sizeOptions = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    '2XL',
    '3XL',
    'Free Size',
  ];

  Set<String> _selectedSizes = {'M'};

  final List<QuickColorItem> _colorOptions = [
    const QuickColorItem(name: 'Black', color: Color(0xFF000000)),
    const QuickColorItem(name: 'White', color: Color(0xFFFFFFFF)),
    const QuickColorItem(name: 'Grey', color: Color(0xFF6B7280)),
    const QuickColorItem(name: 'Navy', color: Color(0xFF1E3A8A)),
    const QuickColorItem(name: 'Blue', color: Color(0xFF3B82F6)),
    const QuickColorItem(name: 'Red', color: Color(0xFFEF4444)),
    const QuickColorItem(name: 'Green', color: Color(0xFF10B981)),
    const QuickColorItem(name: 'Beige', color: Color(0xFFE5DECE)),
    const QuickColorItem(name: 'Brown', color: Color(0xFF78350F)),
    const QuickColorItem(name: 'Pink', color: Color(0xFFEC4899)),
    const QuickColorItem(name: 'Yellow', color: Color(0xFFF59E0B)),
    const QuickColorItem(name: 'Purple', color: Color(0xFF8B5CF6)),
    const QuickColorItem(name: 'Orange', color: Color(0xFFF97316)),
    const QuickColorItem(name: 'Olive', color: Color(0xFF556B2F)),
  ];

  Set<String> _selectedColors = {'Black'};

  @override
  void initState() {
    super.initState();
    _skuCtrl = TextEditingController();
    _updateSkuPreview();

    _sizeCtrl.addListener(() {
      final text = _sizeCtrl.text.trim();
      if (!_isMultiSize && text.isNotEmpty && !_selectedSizes.contains(text)) {
        setState(() {
          _selectedSizes = {text};
        });
      }
    });

    _colorCtrl.addListener(() {
      final text = _colorCtrl.text.trim();
      if (!_isMultiColor && text.isNotEmpty && !_selectedColors.contains(text)) {
        setState(() {
          _selectedColors = {text};
        });
      }
    });
  }

  @override
  void dispose() {
    _skuCtrl.dispose();
    _sizeCtrl.dispose();
    _colorCtrl.dispose();
    _offsetCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _updateSkuPreview() {
    if (!_autoGenerateSku) return;
    final prefix = widget.initialSkuPrefix.isNotEmpty ? widget.initialSkuPrefix.toUpperCase() : 'PROD';

    final isBatch = (_isMultiSize && _selectedSizes.length > 1) ||
                    (_isMultiColor && _selectedColors.length > 1);

    if (isBatch) {
      _skuCtrl.text = '$prefix-VAR';
    } else {
      final size = _sizeCtrl.text.trim().isNotEmpty
          ? _sizeCtrl.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '_')
          : (_selectedSizes.isNotEmpty ? _selectedSizes.first.toUpperCase() : '');
      final color = _colorCtrl.text.trim().isNotEmpty
          ? _colorCtrl.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '_')
          : (_selectedColors.isNotEmpty ? _selectedColors.first.toUpperCase() : '');

      final parts = [prefix];
      if (size.isNotEmpty) parts.add(size);
      if (color.isNotEmpty) parts.add(color);
      _skuCtrl.text = parts.join('-');
    }
  }

  void _onSelectSize(String size) {
    setState(() {
      if (_isMultiSize) {
        if (_selectedSizes.contains(size)) {
          if (_selectedSizes.length > 1) {
            _selectedSizes.remove(size);
          }
        } else {
          _selectedSizes.add(size);
        }
        _sizeCtrl.text = _selectedSizes.join(', ');
      } else {
        _selectedSizes = {size};
        _sizeCtrl.text = size;
      }
      _updateSkuPreview();
    });
  }

  void _onSelectColor(String colorName) {
    setState(() {
      if (_isMultiColor) {
        if (_selectedColors.contains(colorName)) {
          if (_selectedColors.length > 1) {
            _selectedColors.remove(colorName);
          }
        } else {
          _selectedColors.add(colorName);
        }
        _colorCtrl.text = _selectedColors.join(', ');
      } else {
        if (_selectedColors.contains(colorName)) {
          _selectedColors.clear();
          _colorCtrl.clear();
        } else {
          _selectedColors = {colorName};
          _colorCtrl.text = colorName;
        }
      }
      _updateSkuPreview();
    });
  }

  Future<void> _showAddCustomSizeDialog(BuildContext context) async {
    final customCtrl = TextEditingController();
    final commonSizes = ['XXS', '28', '30', '32', '34', '36', '38', '40', '42', 'One Size'];

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.straighten_rounded, color: Color(0xFF2563EB), size: 22),
            SizedBox(width: 8),
            Text(
              'Add Custom Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter size name or pick from common extras:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: customCtrl,
                autofocus: true,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  hintText: 'e.g. 28, 30, XXL, Oversized, 42 EU',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Popular extras:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: commonSizes.map((s) {
                return InkWell(
                  onTap: () => customCtrl.text = s,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = customCtrl.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx, text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Size', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final size = result.trim();
      setState(() {
        if (!_sizeOptions.contains(size)) {
          _sizeOptions.add(size);
        }
        if (_isMultiSize) {
          _selectedSizes.add(size);
          _sizeCtrl.text = _selectedSizes.join(', ');
        } else {
          _selectedSizes = {size};
          _sizeCtrl.text = size;
        }
        _updateSkuPreview();
      });
    }
  }

  Future<void> _showAddCustomColorDialog(BuildContext context) async {
    final customCtrl = TextEditingController();
    Color pickedColor = const Color(0xFF6366F1);

    final palette = [
      const Color(0xFF1E293B), // Charcoal
      const Color(0xFF881337), // Burgundy
      const Color(0xFF047857), // Forest
      const Color(0xFF0369A1), // Sky
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF7C3AED), // Violet
      const Color(0xFFD97706), // Amber
      const Color(0xFFE11D48), // Rose
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFA16207), // Caramel
      const Color(0xFF475569), // Slate
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.palette_rounded, color: Color(0xFF2563EB), size: 22),
              SizedBox(width: 8),
              Text(
                'Add Custom Color',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter color name and pick preview dot color:',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: customCtrl,
                  autofocus: true,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Charcoal, Burgundy, Lavender, Mint',
                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pick swatch dot:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: palette.map((c) {
                  final isPicked = pickedColor == c;
                  return InkWell(
                    onTap: () => setDlgState(() => pickedColor = c),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPicked ? AppColors.primaryLight : Colors.transparent,
                          width: isPicked ? 2.5 : 1,
                        ),
                        boxShadow: [
                          if (isPicked)
                            BoxShadow(
                              color: c.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: isPicked
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = customCtrl.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(ctx, {'name': text, 'color': pickedColor});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add Color', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final name = result['name'] as String;
      final color = result['color'] as Color;
      setState(() {
        if (!_colorOptions.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
          _colorOptions.add(QuickColorItem(name: name, color: color));
        }
        if (_isMultiColor) {
          _selectedColors.add(name);
          _colorCtrl.text = _selectedColors.join(', ');
        } else {
          _selectedColors = {name};
          _colorCtrl.text = name;
        }
        _updateSkuPreview();
      });
    }
  }

  List<AdminVariant> _generateBatchVariants() {
    final prefix = widget.initialSkuPrefix.isNotEmpty ? widget.initialSkuPrefix.toUpperCase() : 'PROD';
    final offset = double.tryParse(_offsetCtrl.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    final List<String?> sizes = _selectedSizes.isNotEmpty
        ? _selectedSizes.toList()
        : (_sizeCtrl.text.trim().isNotEmpty ? [_sizeCtrl.text.trim()] : [null]);

    final List<String?> colors = _selectedColors.isNotEmpty
        ? _selectedColors.toList()
        : (_colorCtrl.text.trim().isNotEmpty ? [_colorCtrl.text.trim()] : [null]);

    final List<AdminVariant> result = [];

    for (final sz in sizes) {
      for (final cl in colors) {
        final List<String> skuParts = [prefix];
        if (sz != null && sz.trim().isNotEmpty) {
          skuParts.add(sz.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '_'));
        }
        if (cl != null && cl.trim().isNotEmpty) {
          skuParts.add(cl.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '_'));
        }
        final generatedSku = skuParts.length > 1 ? skuParts.join('-') : '$prefix-VAR';

        result.add(
          AdminVariant(
            sku: generatedSku,
            size: sz,
            color: cl,
            priceOffset: offset,
            stock: stock,
            isActive: _isActive,
          ),
        );
      }
    }

    return result;
  }

  String _getSubmitButtonText() {
    final batchVariants = _generateBatchVariants();
    if (batchVariants.length <= 1) {
      return 'Add Variant';
    }

    if (_selectedSizes.length > 1 && _selectedColors.length > 1) {
      return 'Add Variants (${_selectedSizes.length} Sizes × ${_selectedColors.length} Colors)';
    } else if (_selectedColors.length > 1) {
      return 'Add ${batchVariants.length} Variants (${_selectedColors.join(", ")})';
    } else {
      return 'Add ${batchVariants.length} Variants (${_selectedSizes.join(", ")})';
    }
  }

  void _submit() {
    final batchVariants = _generateBatchVariants();

    if (batchVariants.length > 1) {
      if (widget.onSubmitMultiple != null) {
        widget.onSubmitMultiple!(batchVariants);
      } else if (widget.onSubmit != null) {
        for (final v in batchVariants) {
          widget.onSubmit!(v);
        }
      }
      return;
    }

    // Single variant
    final sku = _skuCtrl.text.trim();
    if (sku.isEmpty) return;

    final offset = double.tryParse(_offsetCtrl.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    final size = _sizeCtrl.text.trim().isNotEmpty
        ? _sizeCtrl.text.trim()
        : (_selectedSizes.isNotEmpty ? _selectedSizes.first : null);

    final color = _colorCtrl.text.trim().isNotEmpty
        ? _colorCtrl.text.trim()
        : (_selectedColors.isNotEmpty ? _selectedColors.first : null);

    final variant = AdminVariant(
      sku: sku,
      size: size,
      color: color,
      priceOffset: offset,
      stock: stock,
      isActive: _isActive,
    );

    widget.onSubmit?.call(variant);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final batchVariants = _generateBatchVariants();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SIZE SECTION (Quick Options + Custom Add)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.straighten_rounded, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                const Text(
                  'Size Options',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:AppColors.primaryLight,
                  ),
                ),
                if (_selectedSizes.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selectedSizes.length} selected',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // Multi-size Mode Toggle
            InkWell(
              onTap: () {
                setState(() {
                  _isMultiSize = !_isMultiSize;
                  if (!_isMultiSize && _selectedSizes.length > 1) {
                    final first = _selectedSizes.first;
                    _selectedSizes = {first};
                    _sizeCtrl.text = first;
                  }
                  _updateSkuPreview();
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isMultiSize ? AppColors.primaryLight : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isMultiSize ? AppColors.primaryLight : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isMultiSize ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 14,
                      color: _isMultiSize ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Multi-Size',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isMultiSize ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Quick Size Chips Wrap
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._sizeOptions.map((size) {
              final isSelected = _selectedSizes.contains(size);
              return InkWell(
                onTap: () => _onSelectSize(size),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryLight : const Color(0xFFCBD5E1),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        size,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // "+ Add Size" Chip
            InkWell(
              onTap: () => _showAddCustomSizeDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF93C5FD),
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: Color(0xFF2563EB)),
                    SizedBox(width: 4),
                    Text(
                      'Add Size',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildField(
          _isMultiSize ? 'Selected Sizes (Comma Separated)' : 'Size Name',
          _sizeCtrl,
          'e.g. S, M, L, XL',
          onChanged: (_) {
            _updateSkuPreview();
          },
        ),

        const SizedBox(height: 16),

        // COLOR SECTION (Quick Options + Custom Add)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                const Text(
                  'Color Options',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                if (_selectedColors.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selectedColors.length} selected',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // Multi-Color Mode Toggle
            InkWell(
              onTap: () {
                setState(() {
                  _isMultiColor = !_isMultiColor;
                  if (!_isMultiColor && _selectedColors.length > 1) {
                    final first = _selectedColors.first;
                    _selectedColors = {first};
                    _colorCtrl.text = first;
                  }
                  _updateSkuPreview();
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isMultiColor ? AppColors.primaryLight: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isMultiColor ? AppColors.primaryLight : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isMultiColor ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 14,
                      color: _isMultiColor ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Multi-Color',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isMultiColor ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Quick Color Chips Wrap
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._colorOptions.map((opt) {
              final isSelected = _selectedColors.contains(opt.name);
              return InkWell(
                onTap: () => _onSelectColor(opt.name),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryLight : const Color(0xFFCBD5E1),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: opt.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: opt.color == Colors.white ? const Color(0xFFCBD5E1) : Colors.black12,
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        opt.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              );
            }),
            // "+ Add Color" Chip
            InkWell(
              onTap: () => _showAddCustomColorDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF93C5FD),
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: Color(0xFF2563EB)),
                    SizedBox(width: 4),
                    Text(
                      'Add Color',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildField(
          _isMultiColor ? 'Selected Colors (Comma Separated)' : 'Color Name',
          _colorCtrl,
          'e.g. Red, Blue, Heather Grey',
          onChanged: (_) {
            _updateSkuPreview();
          },
        ),

        const SizedBox(height: 16),

        // SKU CODE & AUTO-GENERATION
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SKU Code *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _autoGenerateSku = !_autoGenerateSku;
                  if (_autoGenerateSku) _updateSkuPreview();
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _autoGenerateSku ? Icons.sync_rounded : Icons.lock_outline_rounded,
                      size: 13,
                      color: _autoGenerateSku ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _autoGenerateSku ? 'Auto-generate' : 'Manual SKU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _autoGenerateSku ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _skuCtrl,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              hintText: 'e.g. HOODIE-M-BLACK',
              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),



        const SizedBox(height: 14),

        // pRICE OFFSET & STOCK
        Row(
          children: [
            Expanded(
              child: _buildField(
                'Price Offset (\$) *',
                _offsetCtrl,
                '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildField(
                'Stock Quantity *',
                _stockCtrl,
                '25',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Active Variant Switch
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Active Variant',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Inactive variants will not appear for customer purchase',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          value: _isActive,
          activeThumbColor: AppColors.primaryLight,
          onChanged: (val) => setState(() => _isActive = val),
        ),

        const SizedBox(height: 18),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: widget.isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                  )
                : Text(
                    _getSubmitButtonText(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

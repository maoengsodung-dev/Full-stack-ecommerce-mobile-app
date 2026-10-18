import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';

import '../controllers/home_controller.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {

  List<Map<String, String>> _getSortOptions(BuildContext context) => [
    {'label': context.l10n.featured, 'value': '-created_at'},
    {'label': context.l10n.sortPriceLowHigh, 'value': 'price'},
    {'label': context.l10n.sortPriceHighLow, 'value': '-price'},
    {'label': context.l10n.newDrops, 'value': 'created_at'},
    {'label': context.l10n.sortRating, 'value': '-rating'},
  ];

  // Size options
  final List<String> _sizes = const ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  // Palette colors
  final List<Map<String, dynamic>> _palette = const [
    {'label': 'Ecru', 'color': Color(0xFFF5F0E8)},
    {'label': 'Onyx', 'color': Color(0xFF1C1C1C)},
    {'label': 'Slate', 'color': Color(0xFF78909C)},
    {'label': 'Olive', 'color': Color(0xFF6D6C45)},
    {'label': 'Bone', 'color': Color(0xFFE8E0D0)},
  ];

  // Local state
  static const double _minLimit = 0.0;
  static const double _maxLimit = 2000.0;

  String _selectedSort = '-created_at';
  RangeValues _priceRange = const RangeValues(_minLimit, _maxLimit);
  String? _selectedSize;
  int? _selectedPaletteIndex;

  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    _selectedSort = _controller.selectedSort.value;
    final double rawMin = _controller.minPrice.value ?? _minLimit;
    final double rawMax = _controller.maxPrice.value ?? _maxLimit;
    final double safeMin = rawMin.clamp(_minLimit, _maxLimit);
    final double safeMax = rawMax.clamp(safeMin, _maxLimit);
    _priceRange = RangeValues(safeMin, safeMax);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Scrollable body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: (){
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: AppColors.textSecondary.withValues(alpha: 0.1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.close),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height:30),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.filterAndSort,
                        style:  TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resetAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.l10n.resetAll,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  _divider(),
                  const SizedBox(height: 20),

                  // ── SORT ORDER ──
                  _sectionLabel(context.l10n.sortOrder),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getSortOptions(context).map((opt) {
                      final isSelected = _selectedSort == opt['value'];
                      return _sortPill(
                        label: opt['label']!,
                        value: opt['value']!,
                        isSelected: isSelected,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  _divider(),
                  const SizedBox(height: 20),

                  // ── CATEGORY FILTER ──
                  _sectionLabel(context.l10n.categoryTitle),
                  const SizedBox(height: 12),
                  Obx(() {
                    final cats = _controller.categories;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _categoryPill(label: context.l10n.all, value: null),
                        ...cats.map(
                          (cat) =>
                              _categoryPill(label: cat.name, value: cat.id),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),
                  _divider(),
                  const SizedBox(height: 20),

                  // ── PRICE RANGE ──
                  _sectionLabel(context.l10n.priceRange),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_priceRange.start.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '— \$${_priceRange.end.toStringAsFixed(0)}${_priceRange.end >= _maxLimit ? '+' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: AppColors.primaryLight,
                      inactiveTrackColor: AppColors.textSecondary.withValues(alpha: 0.1),
                      thumbColor: AppColors.primaryLight,
                      overlayColor: AppColors.primaryLight.withAlpha(32),
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: RangeSlider(
                      min: _minLimit,
                      max: _maxLimit,
                      divisions: 100,
                      values: RangeValues(
                        _priceRange.start.clamp(_minLimit, _priceRange.end.clamp(_minLimit, _maxLimit)),
                        _priceRange.end.clamp(_priceRange.start.clamp(_minLimit, _maxLimit), _maxLimit),
                      ),
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _divider(),
                  const SizedBox(height: 20),

                  // ── SIZE ──
                  _sectionLabel(context.l10n.sizeTitle),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sizes.map((s) {
                      final sel = _selectedSize == s;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedSize = sel ? null : s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 48,
                          height: 40,
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primaryLight : AppColors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel ? AppColors.primaryLight : AppColors.textSecondary.withValues(alpha: 0.1),
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.white : AppColors.primaryLight
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  _divider(),
                  const SizedBox(height: 20),

                  // ── PALETTE / COLOR ──
                  _sectionLabel(context.l10n.palette),
                  const SizedBox(height: 12),
                  Row(
                    spacing: 10,
                    children: List.generate(_palette.length, (i) {
                      final p = _palette[i];
                      final sel = _selectedPaletteIndex == i;
                      return GestureDetector(
                        onTap: () => setState(
                          () => _selectedPaletteIndex = sel ? null : i,
                        ),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: p['color'] as Color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: sel
                                      ? AppColors.primaryLight
                                      : (p['color'] as Color) ==
                                            const Color(0xFFF5F0E8)
                                      ? AppColors.textSecondary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  width: sel ? 2.5 : 1,
                                ),
                                boxShadow: sel
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryLight,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: sel
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color:
                                          (p['color'] as Color)
                                                  .computeLuminance() >
                                              0.5
                                          ? AppColors.primaryLight
                                          : Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              p['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: sel ? AppColors.primaryLight : AppColors.textSecondary.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),
                  _divider(),
                  const SizedBox(height: 12),

                  // ── TOGGLES ──
                  Obx(
                    () => _toggleRow(
                      label: context.l10n.featured,
                      value: _controller.featuredOnly.value,
                      onChanged: (v) {
                        _controller.featuredOnly.value = v;
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => _toggleRow(
                      label: context.l10n.inStockLabel,
                      value: _controller.inStockOnly.value,
                      onChanged: (v) {
                        _controller.inStockOnly.value = v;
                      },
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Sticky Bottom Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              border:  Border(top: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.1))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Clear All
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _resetAll,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color:AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.clearAll,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Apply Filters
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: _applyFilters,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withAlpha(100),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.applyFilters,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _divider() {
    return  Divider(color: AppColors.textSecondary.withValues(alpha: 0.1), thickness: 1, height: 1);
  }

  Widget _sortPill({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSort = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary.withValues(alpha: 0.1),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.primaryLight,
          ),
        ),
      ),
    );
  }

  Widget _categoryPill({required String label, required int? value}) {
    return Obx(() {
      final isSelected = _controller.selectedCategory.value == value;
      return GestureDetector(
        onTap: () => _controller.selectedCategory.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryLight : AppColors.textSecondary.withValues(alpha: 0.1),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.primaryLight,
            ),
          ),
        ),
      );
    });
  }

  Widget _toggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryLight,
          ),
        ),
        Transform.scale(
          scale: 0.85,
          child: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor:  AppColors.primaryLight
          ),
        ),
      ],
    );
  }

  void _resetAll() {
    setState(() {
      _selectedSort = '-created_at';
      _priceRange = const RangeValues(_minLimit, _maxLimit);
      _selectedSize = null;
      _selectedPaletteIndex = null;
    });
    _controller.clearFilters();
  }

  void _applyFilters() {
    _controller.selectedSort.value = _selectedSort;
    _controller.minPrice.value = _priceRange.start > _minLimit
        ? _priceRange.start
        : null;
    _controller.maxPrice.value = _priceRange.end < _maxLimit
        ? _priceRange.end
        : null;
    _controller.fetchProducts();
    Get.back();
  }
}

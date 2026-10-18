import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/l10n_extensions.dart';

import '../providers/home_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  static const double _minLimit = 0.0;
  static const double _maxLimit = 2000.0;

  late RangeValues _priceRange;
  bool _featuredOnly = false;
  bool _inStockOnly = true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(homeNotifierProvider);
    final min = (state.minPrice ?? _minLimit).clamp(_minLimit, _maxLimit);
    final max = (state.maxPrice ?? _maxLimit).clamp(min, _maxLimit);
    _priceRange = RangeValues(min, max);
    _featuredOnly = state.featuredOnly;
    _inStockOnly = state.inStockOnly;
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
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.filterAndSort,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  Text(
                    'Price Range (\$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _minLimit,
                    max: _maxLimit,
                    divisions: 40,
                    activeColor: AppColors.primary,
                    onChanged: (vals) => setState(() => _priceRange = vals),
                  ),
                  const SizedBox(height: 16),

                  // Featured & In-Stock Toggles
                  SwitchListTile(
                    title: const Text('Featured Items Only'),
                    value: _featuredOnly,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _featuredOnly = v),
                  ),
                  SwitchListTile(
                    title: const Text('In Stock Only'),
                    value: _inStockOnly,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _inStockOnly = v),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(homeNotifierProvider.notifier)
                                .resetFilters();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(homeNotifierProvider.notifier).applyFilters(
                                  min: _priceRange.start > 0
                                      ? _priceRange.start
                                      : null,
                                  max: _priceRange.end < _maxLimit
                                      ? _priceRange.end
                                      : null,
                                  featured: _featuredOnly,
                                  inStock: _inStockOnly,
                                );
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

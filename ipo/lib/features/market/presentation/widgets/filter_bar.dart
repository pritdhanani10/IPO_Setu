import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/core/constants/app_colors.dart';
import 'package:ipo/core/constants/app_strings.dart';
import 'package:ipo/features/market/presentation/market_controller.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(marketFilterProvider);
    final notifier = ref.read(marketFilterProvider.notifier);

    final statuses = [
      {'key': 'open', 'label': AppStrings.statusOpen},
      {'key': 'upcoming', 'label': AppStrings.statusUpcoming},
      {'key': 'closed', 'label': AppStrings.statusClosed},
      {'key': 'listed', 'label': AppStrings.statusListed},
    ];

    final categories = [
      {'key': 'all', 'label': AppStrings.catAll},
      {'key': 'mainboard', 'label': AppStrings.catMainboard},
      {'key': 'sme', 'label': AppStrings.catSme},
    ];

    return Column(
      children: [
        // Status Tabs
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: statuses.map((item) {
                final isSelected = filter.status == item['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(item['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) notifier.setStatus(item['key']!);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Category Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text(
                'Category: ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              ...categories.map((cat) {
                final isSelected = filter.category == cat['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () => notifier.setCategory(cat['key']!),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        cat['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

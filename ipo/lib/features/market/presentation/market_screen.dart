import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/core/constants/app_colors.dart';
import 'package:ipo/core/constants/app_strings.dart';
import 'package:ipo/shared/widgets/empty_state_widget.dart';
import 'package:ipo/shared/widgets/error_state_widget.dart';
import 'package:ipo/shared/widgets/loading_shimmer.dart';
import 'package:ipo/features/market/presentation/market_controller.dart';
import 'package:ipo/features/market/presentation/widgets/filter_bar.dart';
import 'package:ipo/features/market/presentation/widgets/ipo_card.dart';
import 'package:ipo/features/market/presentation/widgets/market_disclaimer.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iposAsync = ref.watch(iposListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.appName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            Text(
              AppStrings.appTagline,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(iposListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(marketFilterProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                ref.read(marketFilterProvider.notifier).setSearchQuery(val.trim());
              },
            ),
          ),

          // Status & Category Filter Bar
          const FilterBar(),

          // Main List / States
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(iposListProvider);
              },
              child: iposAsync.when(
                data: (ipos) {
                  if (ipos.isEmpty) {
                    return ListView(
                      children: [
                        const MarketDisclaimer(),
                        const SizedBox(height: 60),
                        EmptyStateWidget(
                          title: AppStrings.dataUnavailable,
                          subtitle: AppStrings.dataUnavailableDesc,
                          onRetry: () => ref.invalidate(iposListProvider),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: ipos.length + 1, // +1 for MarketDisclaimer header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const MarketDisclaimer();
                      }
                      final ipo = ipos[index - 1];
                      return IpoCard(ipo: ipo);
                    },
                  );
                },
                loading: () => ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: const [
                    MarketDisclaimer(),
                    IpoCardSkeleton(),
                    IpoCardSkeleton(),
                  ],
                ),
                error: (err, _) => ListView(
                  children: [
                    const MarketDisclaimer(),
                    const SizedBox(height: 60),
                    ErrorStateWidget(
                      message: err.toString(),
                      onRetry: () => ref.invalidate(iposListProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

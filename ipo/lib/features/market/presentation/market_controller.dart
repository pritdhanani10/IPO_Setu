import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/features/market/data/ipo_repository.dart';
import 'package:ipo/features/market/domain/ipo_model.dart';
import 'package:ipo/features/auth/presentation/auth_controller.dart';

final ipoRepositoryProvider = Provider<IpoRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return IpoRepository(dioClient: dioClient);
});

class MarketFilterState {
  final String status;
  final String category;
  final String searchQuery;

  const MarketFilterState({
    this.status = 'open',
    this.category = 'all',
    this.searchQuery = '',
  });

  MarketFilterState copyWith({
    String? status,
    String? category,
    String? searchQuery,
  }) {
    return MarketFilterState(
      status: status ?? this.status,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final marketFilterProvider = StateNotifierProvider<MarketFilterNotifier, MarketFilterState>((ref) {
  return MarketFilterNotifier();
});

class MarketFilterNotifier extends StateNotifier<MarketFilterState> {
  MarketFilterNotifier() : super(const MarketFilterState());

  void setStatus(String status) {
    state = state.copyWith(status: status);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final iposListProvider = FutureProvider.autoDispose<List<IpoModel>>((ref) async {
  final repository = ref.watch(ipoRepositoryProvider);
  final filter = ref.watch(marketFilterProvider);

  return await repository.getIpos(
    status: filter.status,
    category: filter.category,
    search: filter.searchQuery,
  );
});

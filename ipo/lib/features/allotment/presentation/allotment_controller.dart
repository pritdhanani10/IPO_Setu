import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/features/auth/presentation/auth_controller.dart';
import 'package:ipo/features/allotment/data/allotment_repository.dart';
import 'package:ipo/features/allotment/domain/allotment_result_model.dart';

final allotmentRepositoryProvider = Provider<AllotmentRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AllotmentRepository(dioClient: dioClient);
});

class AllotmentSelectionState {
  final String? selectedIpoId;
  final Set<String> selectedPanIds;

  const AllotmentSelectionState({
    this.selectedIpoId,
    this.selectedPanIds = const {},
  });

  AllotmentSelectionState copyWith({
    String? selectedIpoId,
    Set<String>? selectedPanIds,
  }) {
    return AllotmentSelectionState(
      selectedIpoId: selectedIpoId ?? this.selectedIpoId,
      selectedPanIds: selectedPanIds ?? this.selectedPanIds,
    );
  }
}

final allotmentSelectionProvider = StateNotifierProvider<AllotmentSelectionNotifier, AllotmentSelectionState>((ref) {
  return AllotmentSelectionNotifier();
});

class AllotmentSelectionNotifier extends StateNotifier<AllotmentSelectionState> {
  AllotmentSelectionNotifier() : super(const AllotmentSelectionState());

  void selectIpo(String? ipoId) {
    state = state.copyWith(selectedIpoId: ipoId);
  }

  void togglePan(String panId) {
    final updated = Set<String>.from(state.selectedPanIds);
    if (updated.contains(panId)) {
      updated.remove(panId);
    } else {
      updated.add(panId);
    }
    state = state.copyWith(selectedPanIds: updated);
  }

  void selectAllPans(List<String> allPanIds) {
    state = state.copyWith(selectedPanIds: allPanIds.toSet());
  }

  void clearPanSelection() {
    state = state.copyWith(selectedPanIds: {});
  }
}

class AllotmentCheckController extends StateNotifier<AsyncValue<AllotmentCheckResultModel?>> {
  final AllotmentRepository _repository;

  AllotmentCheckController(this._repository) : super(const AsyncValue.data(null));

  Future<AllotmentCheckResultModel?> check({
    required String ipoId,
    required List<String> selectedPanIds,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.checkAllotment(
        ipoId: ipoId,
        selectedPanIds: selectedPanIds,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final allotmentCheckControllerProvider =
    StateNotifierProvider<AllotmentCheckController, AsyncValue<AllotmentCheckResultModel?>>((ref) {
  final repo = ref.watch(allotmentRepositoryProvider);
  return AllotmentCheckController(repo);
});

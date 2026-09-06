import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipo/features/auth/presentation/auth_controller.dart';
import 'package:ipo/features/pans/data/pan_repository.dart';
import 'package:ipo/features/pans/domain/saved_pan_model.dart';

final panRepositoryProvider = Provider<PanRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PanRepository(dioClient: dioClient);
});

final savedPansProvider = FutureProvider.autoDispose<List<SavedPanModel>>((ref) async {
  final repo = ref.watch(panRepositoryProvider);
  return await repo.getPans();
});

class PanActionController extends StateNotifier<AsyncValue<void>> {
  final PanRepository _repository;
  final Ref _ref;

  PanActionController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> addPan(String pan, String? label) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addPan(pan, label);
      _ref.invalidate(savedPansProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deletePan(String panId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deletePan(panId);
      _ref.invalidate(savedPansProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final panActionControllerProvider = StateNotifierProvider<PanActionController, AsyncValue<void>>((ref) {
  final repo = ref.watch(panRepositoryProvider);
  return PanActionController(repo, ref);
});

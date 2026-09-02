import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pace_amigo/core/providers/core_providers.dart';
import 'package:pace_amigo/features/presets/data/preset_repository.dart';
import 'package:pace_amigo/features/presets/models/routine_preset.dart';

class PresetNotifier extends StateNotifier<AsyncValue<List<RoutinePreset>>> {
  final PresetRepository _repo;
  final Ref _ref;

  PresetNotifier(this._repo, this._ref) : super(const AsyncValue.loading()) {
    loadPresets();
  }

  Future<void> loadPresets() async {
    state = const AsyncValue.loading();
    try {
      await _repo.init();
      final list = await _repo.getPresets();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePreset(RoutinePreset preset) async {
    try {
      await _repo.savePreset(preset);
      await loadPresets();
      // Inform sync service
      _ref.read(cloudSyncServiceProvider).triggerSync();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await _repo.deletePreset(id);
      await loadPresets();
      _ref.read(cloudSyncServiceProvider).triggerSync();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final presetsProvider =
    StateNotifierProvider<PresetNotifier, AsyncValue<List<RoutinePreset>>>((ref) {
  final repo = ref.watch(presetRepositoryProvider);
  return PresetNotifier(repo, ref);
});

import '../models/routine_preset.dart';

abstract class PresetRepository {
  Future<void> init();
  Future<List<RoutinePreset>> getPresets();
  Future<RoutinePreset?> getPresetById(String id);
  Future<void> savePreset(RoutinePreset preset);
  Future<void> deletePreset(String id);
}

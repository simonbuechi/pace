import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../../features/presets/data/preset_repository.dart';
import '../../features/presets/data/hive_preset_repository.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService();
});

final presetRepositoryProvider = Provider<PresetRepository>((ref) {
  return HivePresetRepository();
});

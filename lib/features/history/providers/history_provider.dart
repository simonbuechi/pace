import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:pace_amigo/features/history/models/focus_run_log.dart';
import 'package:pace_amigo/features/history/services/history_sync_service.dart';
import 'package:pace_amigo/features/timer/models/timer_state.dart';

class HistoryNotifier extends StateNotifier<List<FocusRunLog>> {
  static const String _boxName = 'pace_history_box';
  final HistorySyncService _syncService;
  Box<String>? _box;
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  HistoryNotifier({HistorySyncService? syncService})
      : _syncService = syncService ?? HistorySyncService(),
        super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<String>(_boxName);
      } else {
        _box = Hive.box<String>(_boxName);
      }

      final logs = <FocusRunLog>[];
      for (final key in _box!.keys) {
        final raw = _box!.get(key);
        if (raw != null) {
          try {
            logs.add(FocusRunLog.fromJson(raw));
          } catch (e) {
            debugPrint('Error parsing log entry $key: $e');
          }
        }
      }

      // Sort newest first
      logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      state = logs;

      // Automatically sync any pending unsynced logs in background
      _syncPending();
    } catch (e) {
      debugPrint('HistoryNotifier load error: $e');
    }
  }

  Future<void> _persistLog(FocusRunLog log) async {
    if (_box != null && _box!.isOpen) {
      await _box!.put(log.id, log.toJson());
    }
  }

  /// Records a successfully completed focus run.
  Future<void> recordRunFromTimer(TimerState timerState) async {
    // Calculate total focus seconds across all completed cycles
    final focusPerCycle = timerState.preset.phases
        .where((p) => p.isFocus)
        .fold<int>(0, (sum, p) => sum + p.durationInSeconds);
    final totalFocusSeconds = focusPerCycle * timerState.preset.iterations;

    final log = FocusRunLog(
      id: const Uuid().v4(),
      presetId: timerState.preset.id,
      presetName: timerState.preset.name,
      focusDurationSeconds: totalFocusSeconds > 0
          ? totalFocusSeconds
          : timerState.preset.totalDurationSeconds,
      totalDurationSeconds: timerState.preset.totalDurationSeconds,
      iterations: timerState.preset.iterations,
      completedAt: DateTime.now(),
      isSynced: false,
    );

    // Update local state immediately
    state = [log, ...state];
    await _persistLog(log);

    // Sync to Firebase in background
    _syncSingleLog(log);
  }

  Future<void> _syncSingleLog(FocusRunLog log) async {
    final success = await _syncService.syncLog(log);
    if (success) {
      final updatedLog = log.copyWith(isSynced: true);
      state = state.map((item) => item.id == log.id ? updatedLog : item).toList();
      await _persistLog(updatedLog);
    }
  }

  Future<void> _syncPending() async {
    final pending = state.where((l) => !l.isSynced).toList();
    if (pending.isEmpty) return;

    _isSyncing = true;
    final syncedIds = await _syncService.syncBatch(pending);
    if (syncedIds.isNotEmpty) {
      state = state.map((item) {
        if (syncedIds.contains(item.id)) {
          final updated = item.copyWith(isSynced: true);
          _persistLog(updated);
          return updated;
        }
        return item;
      }).toList();
    }
    _isSyncing = false;
  }

  /// Trigger manual re-sync of all runs
  Future<void> syncAll() async {
    _isSyncing = true;
    state = [...state];
    await _syncPending();
    _isSyncing = false;
    state = [...state];
  }

  /// Remove a specific log entry
  Future<void> deleteLog(String id) async {
    state = state.where((l) => l.id != id).toList();
    if (_box != null && _box!.isOpen) {
      await _box!.delete(id);
    }
  }

  /// Clear entire run history
  Future<void> clearHistory() async {
    state = [];
    if (_box != null && _box!.isOpen) {
      await _box!.clear();
    }
  }
}

final historySyncServiceProvider = Provider<HistorySyncService>((ref) {
  return HistorySyncService();
});

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<FocusRunLog>>((ref) {
  final syncService = ref.watch(historySyncServiceProvider);
  return HistoryNotifier(syncService: syncService);
});

final totalFocusMinutesProvider = Provider<int>((ref) {
  final logs = ref.watch(historyProvider);
  final totalSec = logs.fold<int>(0, (sum, l) => sum + l.focusDurationSeconds);
  return totalSec ~/ 60;
});

final todayRunsCountProvider = Provider<int>((ref) {
  final logs = ref.watch(historyProvider);
  final now = DateTime.now();
  return logs.where((l) {
    return l.completedAt.year == now.year &&
        l.completedAt.month == now.month &&
        l.completedAt.day == now.day;
  }).length;
});

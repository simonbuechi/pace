import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pace_amigo/features/history/models/focus_run_log.dart';
import 'package:pace_amigo/features/history/providers/history_provider.dart';
import 'package:pace_amigo/features/presets/models/routine_preset.dart';
import 'package:pace_amigo/features/timer/models/interval_phase.dart';
import 'package:pace_amigo/features/timer/models/timer_state.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('history_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FocusRunLog Tests', () {
    test('FocusRunLog serialization & deserialization', () {
      final now = DateTime.now();
      final log = FocusRunLog(
        id: 'run_123',
        presetId: 'quick_start',
        presetName: 'Quick Focus',
        focusDurationSeconds: 1500,
        totalDurationSeconds: 1800,
        iterations: 4,
        completedAt: now,
        isSynced: true,
      );

      final json = log.toJson();
      final revived = FocusRunLog.fromJson(json);

      expect(revived.id, 'run_123');
      expect(revived.presetName, 'Quick Focus');
      expect(revived.focusDurationSeconds, 1500);
      expect(revived.iterations, 4);
      expect(revived.isSynced, true);
    });

    test('FocusRunLog formattedDuration handles minutes and seconds', () {
      final logSec = FocusRunLog(
        id: '1',
        presetId: 'p',
        presetName: 'Sprint',
        focusDurationSeconds: 45,
        totalDurationSeconds: 45,
        iterations: 1,
        completedAt: DateTime(2026, 1, 1),
      );
      expect(logSec.formattedDuration, '45s');

      final logMin = FocusRunLog(
        id: '2',
        presetId: 'p',
        presetName: 'Sprint',
        focusDurationSeconds: 1500,
        totalDurationSeconds: 1500,
        iterations: 1,
        completedAt: DateTime(2026, 1, 1),
      );
      expect(logMin.formattedDuration, '25m');

      final logMixed = FocusRunLog(
        id: '3',
        presetId: 'p',
        presetName: 'Sprint',
        focusDurationSeconds: 1530,
        totalDurationSeconds: 1530,
        iterations: 1,
        completedAt: DateTime(2026, 1, 1),
      );
      expect(logMixed.formattedDuration, '25m 30s');
    });
  });

  group('HistoryNotifier Tests', () {
    test('Records completed timer run accurately', () async {
      final notifier = HistoryNotifier();

      final preset = RoutinePreset(
        id: 'preset_tabata',
        name: 'HIIT Tabata',
        description: 'Test run',
        iterations: 2,
        createdAt: DateTime(2026, 1, 1),
        phases: const [
          IntervalPhase(
            id: 'ph1',
            type: IntervalPhaseType.focus,
            name: 'Sprint',
            durationInSeconds: 30,
          ),
          IntervalPhase(
            id: 'ph2',
            type: IntervalPhaseType.shortBreak,
            name: 'Rest',
            durationInSeconds: 15,
          ),
        ],
      );

      final completedTimerState = TimerState(
        preset: preset,
        currentIteration: 2,
        currentPhaseIndex: 1,
        remainingSeconds: 0,
        totalPhaseSeconds: 15,
        isRunning: false,
        isPaused: false,
        isCompleted: true,
      );

      await notifier.recordRunFromTimer(completedTimerState);

      expect(notifier.state.length, 1);
      final log = notifier.state.first;
      expect(log.presetName, 'HIIT Tabata');
      // 30s focus * 2 iterations = 60s
      expect(log.focusDurationSeconds, 60);
      expect(log.iterations, 2);

      // Clean up
      await notifier.clearHistory();
      expect(notifier.state.isEmpty, true);
    });
  });
}

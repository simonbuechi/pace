import 'package:flutter_test/flutter_test.dart';
import 'package:pace_amigo/features/presets/models/routine_preset.dart';
import 'package:pace_amigo/features/timer/models/interval_phase.dart';
import 'package:pace_amigo/features/timer/models/timer_state.dart';

void main() {
  group('RoutinePreset & IntervalPhase Tests', () {
    test('Standard RoutinePreset computes total duration accurately', () {
      final preset = RoutinePreset.createStandard(
        id: 'test_standard',
        name: 'Test Pomodoro',
        description: 'Testing',
        focusMinutes: 25,
        breakMinutes: 5,
        iterations: 4,
      );

      // (25 * 60 + 5 * 60) * 4 = 1800 * 4 = 7200 seconds = 120 minutes = 2 hours
      expect(preset.totalDurationSeconds, equals(7200));
      expect(preset.formattedTotalDuration, equals('2h 0m'));
      expect(preset.phases.length, equals(2));
      expect(preset.phases[0].type, equals(IntervalPhaseType.focus));
      expect(preset.phases[1].type, equals(IntervalPhaseType.shortBreak));
    });

    test('Custom multi-phase RoutinePreset serialization and deserialization', () {
      final preset = RoutinePreset(
        id: 'test_custom',
        name: 'HIIT Tabata',
        description: 'High intensity interval training',
        iterations: 8,
        isCustomSequence: true,
        createdAt: DateTime.parse('2026-09-01T10:00:00.000Z'),
        phases: const [
          IntervalPhase(
            id: 'p1',
            type: IntervalPhaseType.custom,
            name: 'Warmup',
            durationInSeconds: 15,
          ),
          IntervalPhase(
            id: 'p2',
            type: IntervalPhaseType.focus,
            name: 'Sprint',
            durationInSeconds: 30,
          ),
          IntervalPhase(
            id: 'p3',
            type: IntervalPhaseType.shortBreak,
            name: 'Rest',
            durationInSeconds: 15,
          ),
        ],
      );

      final json = preset.toJson();
      final revived = RoutinePreset.fromJson(json);

      expect(revived.id, equals(preset.id));
      expect(revived.name, equals(preset.name));
      expect(revived.iterations, equals(8));
      expect(revived.phases.length, equals(3));
      expect(revived.phases[0].name, equals('Warmup'));
      expect(revived.phases[1].name, equals('Sprint'));
      expect(revived.phases[2].name, equals('Rest'));
      expect(revived.totalDurationSeconds, equals(60 * 8)); // 480 seconds
    });

    test('TimerState progress and time formatting works as expected', () {
      final preset = RoutinePreset.createStandard(
        id: 't_state',
        name: 'Quick',
        description: 'Desc',
        focusMinutes: 25,
        breakMinutes: 5,
        iterations: 2,
      );

      final state = TimerState(
        preset: preset,
        currentIteration: 1,
        currentPhaseIndex: 0,
        remainingSeconds: 750, // halfway through 1500
        totalPhaseSeconds: 1500,
        isRunning: true,
      );

      expect(state.progress, closeTo(0.5, 0.001));
      expect(state.formattedRemainingTime, equals('12:30'));
      expect(state.currentPhase.name, equals('Focus'));
      expect(state.currentPhase.isFocus, isTrue);
      expect(state.iterationBadge, equals('Cycle 1 of 2'));
    });
  });
}

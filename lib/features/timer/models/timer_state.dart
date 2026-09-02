import 'interval_phase.dart';
import '../../presets/models/routine_preset.dart';

class TimerState {
  final RoutinePreset preset;
  final int currentIteration; // 1-indexed
  final int currentPhaseIndex; // 0-indexed
  final int remainingSeconds;
  final int totalPhaseSeconds;
  final bool isRunning;
  final bool isPaused;
  final bool isCompleted;

  const TimerState({
    required this.preset,
    required this.currentIteration,
    required this.currentPhaseIndex,
    required this.remainingSeconds,
    required this.totalPhaseSeconds,
    this.isRunning = false,
    this.isPaused = false,
    this.isCompleted = false,
  });

  IntervalPhase get currentPhase {
    if (preset.phases.isEmpty) {
      return const IntervalPhase(
        id: 'fallback',
        type: IntervalPhaseType.focus,
        name: 'Focus',
        durationInSeconds: 1500,
      );
    }
    final safeIndex = currentPhaseIndex.clamp(0, preset.phases.length - 1);
    return preset.phases[safeIndex];
  }

  double get progress {
    if (totalPhaseSeconds == 0) return 0.0;
    final elapsed = totalPhaseSeconds - remainingSeconds;
    return (elapsed / totalPhaseSeconds).clamp(0.0, 1.0);
  }

  String get formattedRemainingTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  String get iterationBadge =>
      'Cycle $currentIteration of ${preset.iterations}';

  TimerState copyWith({
    RoutinePreset? preset,
    int? currentIteration,
    int? currentPhaseIndex,
    int? remainingSeconds,
    int? totalPhaseSeconds,
    bool? isRunning,
    bool? isPaused,
    bool? isCompleted,
  }) {
    return TimerState(
      preset: preset ?? this.preset,
      currentIteration: currentIteration ?? this.currentIteration,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalPhaseSeconds: totalPhaseSeconds ?? this.totalPhaseSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pace_amigo/core/providers/core_providers.dart';
import 'package:pace_amigo/features/presets/models/routine_preset.dart';
import 'package:pace_amigo/features/timer/models/interval_phase.dart';
import 'package:pace_amigo/features/timer/models/timer_state.dart';
import 'package:pace_amigo/features/settings/providers/settings_provider.dart';
import 'package:pace_amigo/features/history/providers/history_provider.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _timer;

  TimerNotifier(this._ref)
      : super(
          TimerState(
            preset: RoutinePreset.createStandard(
              id: 'quick_start_default',
              name: 'Quick Start',
              description: 'Standard 25/5 interval',
              focusMinutes: 25,
              breakMinutes: 5,
              iterations: 4,
            ),
            currentIteration: 1,
            currentPhaseIndex: 0,
            remainingSeconds: 25 * 60,
            totalPhaseSeconds: 25 * 60,
            isRunning: false,
            isPaused: false,
            isCompleted: false,
          ),
        );

  /// Load a routine preset and reset state
  void loadPreset(RoutinePreset preset) {
    _cancelTimer();
    final firstPhase = preset.phases.isNotEmpty
        ? preset.phases.first
        : const IntervalPhase(
            id: 'default',
            type: IntervalPhaseType.focus,
            name: 'Focus',
            durationInSeconds: 25 * 60,
          );

    state = TimerState(
      preset: preset,
      currentIteration: 1,
      currentPhaseIndex: 0,
      remainingSeconds: firstPhase.durationInSeconds,
      totalPhaseSeconds: firstPhase.durationInSeconds,
      isRunning: false,
      isPaused: false,
      isCompleted: false,
    );
  }

  /// Start or resume timer
  void start() {
    if (state.isCompleted) {
      reset();
    }
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true, isPaused: false);
    _playPhaseAlert(state.currentPhase);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  /// Pause timer
  void pause() {
    _cancelTimer();
    state = state.copyWith(isRunning: false, isPaused: true);
  }

  /// Resume timer
  void resume() {
    start();
  }

  /// Reset active routine back to beginning
  void reset() {
    _cancelTimer();
    final firstPhase = state.preset.phases.isNotEmpty
        ? state.preset.phases.first
        : const IntervalPhase(
            id: 'default',
            type: IntervalPhaseType.focus,
            name: 'Focus',
            durationInSeconds: 25 * 60,
          );

    state = state.copyWith(
      currentIteration: 1,
      currentPhaseIndex: 0,
      remainingSeconds: firstPhase.durationInSeconds,
      totalPhaseSeconds: firstPhase.durationInSeconds,
      isRunning: false,
      isPaused: false,
      isCompleted: false,
    );
  }

  /// Skip to next interval phase
  void skipNext() {
    _cancelTimer();
    _advanceToNextPhase();
  }

  /// Skip to previous phase or restart current phase
  void skipPrevious() {
    _cancelTimer();
    if (state.remainingSeconds < state.totalPhaseSeconds - 3) {
      // If we've already run 3+ seconds into the phase, restart current phase
      state = state.copyWith(
        remainingSeconds: state.totalPhaseSeconds,
        isRunning: false,
        isPaused: true,
      );
      return;
    }

    // Go to previous phase
    if (state.currentPhaseIndex > 0) {
      final prevIndex = state.currentPhaseIndex - 1;
      final prevPhase = state.preset.phases[prevIndex];
      state = state.copyWith(
        currentPhaseIndex: prevIndex,
        remainingSeconds: prevPhase.durationInSeconds,
        totalPhaseSeconds: prevPhase.durationInSeconds,
        isRunning: false,
        isPaused: true,
      );
    } else if (state.currentIteration > 1) {
      final prevIteration = state.currentIteration - 1;
      final lastIndex = state.preset.phases.length - 1;
      final lastPhase = state.preset.phases[lastIndex];
      state = state.copyWith(
        currentIteration: prevIteration,
        currentPhaseIndex: lastIndex,
        remainingSeconds: lastPhase.durationInSeconds,
        totalPhaseSeconds: lastPhase.durationInSeconds,
        isRunning: false,
        isPaused: true,
      );
    }
  }

  void _tick() {
    if (state.remainingSeconds > 1) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else {
      _advanceToNextPhase();
    }
  }

  void _advanceToNextPhase() {
    final hasNextPhaseInCycle =
        state.currentPhaseIndex + 1 < state.preset.phases.length;

    if (hasNextPhaseInCycle) {
      final nextIndex = state.currentPhaseIndex + 1;
      final nextPhase = state.preset.phases[nextIndex];
      state = state.copyWith(
        currentPhaseIndex: nextIndex,
        remainingSeconds: nextPhase.durationInSeconds,
        totalPhaseSeconds: nextPhase.durationInSeconds,
      );
      _playPhaseAlert(nextPhase);
    } else {
      // Iteration complete
      final hasNextIteration = state.currentIteration < state.preset.iterations;
      if (hasNextIteration) {
        final nextIteration = state.currentIteration + 1;
        final firstPhase = state.preset.phases.first;
        state = state.copyWith(
          currentIteration: nextIteration,
          currentPhaseIndex: 0,
          remainingSeconds: firstPhase.durationInSeconds,
          totalPhaseSeconds: firstPhase.durationInSeconds,
        );
        _playPhaseAlert(firstPhase);
      } else {
        // Complete entire routine
        _cancelTimer();
        state = state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
          isPaused: false,
          isCompleted: true,
        );
        _onRoutineCompleted();
      }
    }
  }

  void _playPhaseAlert(IntervalPhase phase) {
    final settings = _ref.read(settingsProvider);
    final audio = _ref.read(audioServiceProvider);
    final notif = _ref.read(notificationServiceProvider);

    if (phase.isFocus) {
      audio.playFocusStartSound(settings.focusSoundId);
      notif.showIntervalAlert(
        title: 'Focus Time 🎯',
        body: '${phase.name}: Time to lock in and do your best work.',
      );
    } else {
      audio.playBreakStartSound(settings.breakSoundId);
      notif.showIntervalAlert(
        title: 'Break Time ☕',
        body: '${phase.name}: Take a breather, hydrate, and stretch.',
      );
    }
  }

  void _onRoutineCompleted() {
    final settings = _ref.read(settingsProvider);
    final audio = _ref.read(audioServiceProvider);
    final notif = _ref.read(notificationServiceProvider);

    audio.playBreakStartSound(settings.breakSoundId);
    notif.showIntervalAlert(
      title: 'Routine Completed! 🎉',
      body: 'Outstanding session! All intervals successfully completed.',
    );

    // Automatically log finished focus run (persisted locally and synced with Firebase)
    _ref.read(historyProvider.notifier).recordRunFromTimer(state);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

import React, { createContext, useContext, useEffect, useRef, useState } from 'react';
import confetti from 'canvas-confetti';
import type { IntervalPhase, RoutinePreset, TimerState, RoutineLog } from '../types';
import { DEFAULT_PRESETS } from '../core/storage';
import { useSettings } from './SettingsContext';
import { usePresets } from './PresetsContext';
import { audioController } from '../core/audio';
import { notificationController } from '../core/notifications';

interface TimerContextType {
  state: TimerState;
  currentPhase: IntervalPhase;
  progress: number; // 0.0 (start) to 1.0 (completed)
  formattedTime: string;
  isVisualizerOpen: boolean;
  openVisualizer: () => void;
  closeVisualizer: () => void;
  loadPreset: (preset: RoutinePreset, autoStart?: boolean) => void;
  start: () => void;
  pause: () => void;
  resume: () => void;
  reset: () => void;
  skipNext: () => void;
  skipPrevious: () => void;
  toggleFullscreen: () => void;
}

const TimerContext = createContext<TimerContextType | null>(null);

export const TimerProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { settings } = useSettings();
  const { addRoutineLog } = usePresets();

  const [state, setState] = useState<TimerState>(() => {
    const initialPreset = DEFAULT_PRESETS[0];
    const initialPhase = initialPreset.phases[0];
    return {
      preset: initialPreset,
      currentIteration: 1,
      currentPhaseIndex: 0,
      remainingSeconds: initialPhase.durationInSeconds,
      totalPhaseSeconds: initialPhase.durationInSeconds,
      isRunning: false,
      isPaused: false,
      isCompleted: false,
    };
  });

  const [isVisualizerOpen, setIsVisualizerOpen] = useState(false);

  // Drift compensation target
  const targetEndRef = useRef<number | null>(null);

  const currentPhase: IntervalPhase =
    state.preset.phases[state.currentPhaseIndex] || state.preset.phases[0];

  const progress =
    state.totalPhaseSeconds > 0
      ? Math.min(1, Math.max(0, (state.totalPhaseSeconds - state.remainingSeconds) / state.totalPhaseSeconds))
      : 0;

  const minutes = Math.floor(state.remainingSeconds / 60);
  const seconds = state.remainingSeconds % 60;
  const formattedTime = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

  // Update browser document title with ticking time
  useEffect(() => {
    if (state.isRunning) {
      document.title = `${formattedTime} • ${currentPhase.name} | Pace Amigo`;
    } else {
      document.title = 'Pace Amigo • Minimalist Interval Timer';
    }
  }, [state.isRunning, formattedTime, currentPhase.name]);

  // Main high-precision tick loop with wall-clock drift compensation
  useEffect(() => {
    if (!state.isRunning) {
      targetEndRef.current = null;
      return;
    }

    if (!targetEndRef.current) {
      targetEndRef.current = Date.now() + state.remainingSeconds * 1000;
    }

    const interval = setInterval(() => {
      if (!targetEndRef.current) return;

      const now = Date.now();
      const remainingMs = targetEndRef.current - now;
      const remainingSec = Math.max(0, Math.ceil(remainingMs / 1000));

      if (remainingSec <= 0) {
        advancePhase();
      } else {
        setState((prev) => {
          if (prev.remainingSeconds === remainingSec) return prev;
          return { ...prev, remainingSeconds: remainingSec };
        });
      }
    }, 200);

    // Sync immediately when tab becomes visible again
    const handleVisibilityChange = () => {
      if (document.visibilityState === 'visible' && targetEndRef.current && state.isRunning) {
        const remainingSec = Math.max(0, Math.ceil((targetEndRef.current - Date.now()) / 1000));
        if (remainingSec <= 0) {
          advancePhase();
        } else {
          setState((prev) => ({ ...prev, remainingSeconds: remainingSec }));
        }
      }
    };

    document.addEventListener('visibilitychange', handleVisibilityChange);

    return () => {
      clearInterval(interval);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, [state.isRunning, state.remainingSeconds]);

  const playPhaseSound = (phase: IntervalPhase) => {
    if (!settings.soundEnabled) return;
    const isFocus = phase.type === 'focus';
    const soundId = isFocus ? settings.focusSoundId : settings.breakSoundId;
    audioController.playSound(soundId, settings.soundVolume);
  };

  const sendPhaseNotification = (phase: IntervalPhase) => {
    if (!settings.notificationsEnabled) return;
    const isFocus = phase.type === 'focus';
    notificationController.show(isFocus ? 'Focus Time 🎯' : 'Break Time ☕', {
      body: `${phase.name}: ${isFocus ? 'Time to focus and lock in!' : 'Take a breath and recharge.'}`,
    });
  };

  const advancePhase = () => {
    const hasNextPhase = state.currentPhaseIndex + 1 < state.preset.phases.length;

    if (hasNextPhase) {
      const nextIndex = state.currentPhaseIndex + 1;
      const nextPhase = state.preset.phases[nextIndex];

      targetEndRef.current = Date.now() + nextPhase.durationInSeconds * 1000;
      setState((prev) => ({
        ...prev,
        currentPhaseIndex: nextIndex,
        remainingSeconds: nextPhase.durationInSeconds,
        totalPhaseSeconds: nextPhase.durationInSeconds,
      }));

      playPhaseSound(nextPhase);
      sendPhaseNotification(nextPhase);
    } else {
      // Current iteration complete
      const hasNextIteration = state.currentIteration < state.preset.iterations;

      if (hasNextIteration) {
        const nextIteration = state.currentIteration + 1;
        const firstPhase = state.preset.phases[0];

        targetEndRef.current = Date.now() + firstPhase.durationInSeconds * 1000;
        setState((prev) => ({
          ...prev,
          currentIteration: nextIteration,
          currentPhaseIndex: 0,
          remainingSeconds: firstPhase.durationInSeconds,
          totalPhaseSeconds: firstPhase.durationInSeconds,
        }));

        playPhaseSound(firstPhase);
        sendPhaseNotification(firstPhase);
      } else {
        // Entire routine complete!
        targetEndRef.current = null;
        setState((prev) => ({
          ...prev,
          remainingSeconds: 0,
          isRunning: false,
          isPaused: false,
          isCompleted: true,
        }));

        // Log successful completion
        try {
          const cycleSecs = state.preset.phases.reduce((acc, p) => acc + p.durationInSeconds, 0);
          const totalDuration = cycleSecs * state.preset.iterations;
          const focusSecs = state.preset.phases
            .filter((p) => p.type === 'focus')
            .reduce((acc, p) => acc + p.durationInSeconds, 0) * state.preset.iterations;
          const breakSecs = totalDuration - focusSecs;

          const log: RoutineLog = {
            id: `log_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
            presetId: state.preset.id,
            presetName: state.preset.name,
            completedAt: new Date().toISOString(),
            totalDurationInSeconds: totalDuration,
            cyclesCompleted: state.preset.iterations,
            focusDurationInSeconds: focusSecs,
            breakDurationInSeconds: breakSecs,
          };
          addRoutineLog(log);
        } catch (e) {
          console.warn('Failed to save routine completion log:', e);
        }

        // Celebratory confetti and alert
        try {
          confetti({
            particleCount: 80,
            spread: 70,
            origin: { y: 0.6 },
          });
        } catch {}

        if (settings.soundEnabled) {
          audioController.playSound(settings.breakSoundId, settings.soundVolume);
        }
        if (settings.notificationsEnabled) {
          notificationController.show('Routine Completed! 🎉', {
            body: `Congratulations! Completed all ${state.preset.iterations} cycles of ${state.preset.name}.`,
          });
        }
      }
    }
  };

  const loadPreset = (preset: RoutinePreset, autoStart = false) => {
    targetEndRef.current = null;
    const firstPhase = preset.phases[0] || {
      id: 'default',
      type: 'focus',
      name: 'Focus Block',
      durationInSeconds: 25 * 60,
    };

    setState({
      preset,
      currentIteration: 1,
      currentPhaseIndex: 0,
      remainingSeconds: firstPhase.durationInSeconds,
      totalPhaseSeconds: firstPhase.durationInSeconds,
      isRunning: autoStart,
      isPaused: false,
      isCompleted: false,
    });

    if (autoStart) {
      targetEndRef.current = Date.now() + firstPhase.durationInSeconds * 1000;
      playPhaseSound(firstPhase);
    }

    setIsVisualizerOpen(true);
  };

  const start = () => {
    if (state.isCompleted) {
      reset();
    }
    targetEndRef.current = Date.now() + state.remainingSeconds * 1000;
    setState((prev) => ({ ...prev, isRunning: true, isPaused: false }));
    playPhaseSound(currentPhase);
  };

  const pause = () => {
    targetEndRef.current = null;
    setState((prev) => ({ ...prev, isRunning: false, isPaused: true }));
  };

  const resume = () => {
    start();
  };

  const reset = () => {
    targetEndRef.current = null;
    const firstPhase = state.preset.phases[0];
    setState((prev) => ({
      ...prev,
      currentIteration: 1,
      currentPhaseIndex: 0,
      remainingSeconds: firstPhase.durationInSeconds,
      totalPhaseSeconds: firstPhase.durationInSeconds,
      isRunning: false,
      isPaused: false,
      isCompleted: false,
    }));
  };

  const skipNext = () => {
    advancePhase();
  };

  const skipPrevious = () => {
    targetEndRef.current = null;
    if (state.remainingSeconds < state.totalPhaseSeconds - 3) {
      // Restart current phase if more than 3s elapsed
      setState((prev) => ({
        ...prev,
        remainingSeconds: prev.totalPhaseSeconds,
        isRunning: false,
        isPaused: true,
      }));
      return;
    }

    if (state.currentPhaseIndex > 0) {
      const prevIndex = state.currentPhaseIndex - 1;
      const prevPhase = state.preset.phases[prevIndex];
      setState((prev) => ({
        ...prev,
        currentPhaseIndex: prevIndex,
        remainingSeconds: prevPhase.durationInSeconds,
        totalPhaseSeconds: prevPhase.durationInSeconds,
        isRunning: false,
        isPaused: true,
      }));
    } else if (state.currentIteration > 1) {
      const prevIteration = state.currentIteration - 1;
      const lastIndex = state.preset.phases.length - 1;
      const lastPhase = state.preset.phases[lastIndex];
      setState((prev) => ({
        ...prev,
        currentIteration: prevIteration,
        currentPhaseIndex: lastIndex,
        remainingSeconds: lastPhase.durationInSeconds,
        totalPhaseSeconds: lastPhase.durationInSeconds,
        isRunning: false,
        isPaused: true,
      }));
    }
  };

  const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(() => {});
    } else {
      document.exitFullscreen().catch(() => {});
    }
  };

  const openVisualizer = () => setIsVisualizerOpen(true);
  const closeVisualizer = () => setIsVisualizerOpen(false);

  return (
    <TimerContext.Provider
      value={{
        state,
        currentPhase,
        progress,
        formattedTime,
        isVisualizerOpen,
        openVisualizer,
        closeVisualizer,
        loadPreset,
        start,
        pause,
        resume,
        reset,
        skipNext,
        skipPrevious,
        toggleFullscreen,
      }}
    >
      {children}
    </TimerContext.Provider>
  );
};

export const useTimer = (): TimerContextType => {
  const ctx = useContext(TimerContext);
  if (!ctx) throw new Error('useTimer must be used within TimerProvider');
  return ctx;
};

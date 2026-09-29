import React, { useEffect, useState } from 'react';
import {
  Play,
  Pause,
  SkipForward,
  SkipBack,
  RotateCcw,
  Volume2,
  VolumeX,
  Maximize2,
  Minimize2,
  ArrowLeft,
  Trophy,
  Sparkles,
} from 'lucide-react';
import { useTimer } from '../../context/TimerContext';
import { useSettings } from '../../context/SettingsContext';

export const TimerVisualizer: React.FC = () => {
  const {
    state,
    currentPhase,
    progress,
    formattedTime,
    closeVisualizer,
    start,
    pause,
    reset,
    skipNext,
    skipPrevious,
    toggleFullscreen,
  } = useTimer();

  const { activeFocusColor, activeBreakColor, settings, toggleSound } = useSettings();

  const [controlsVisible, setControlsVisible] = useState(true);
  const [isFullscreen, setIsFullscreen] = useState(false);

  // Background color calculation
  let targetBgColor: string;
  if (state.isCompleted) {
    targetBgColor = '#1E293B'; // Slate completed
  } else if (currentPhase.color) {
    targetBgColor = currentPhase.color;
  } else if (currentPhase.type === 'focus') {
    targetBgColor = activeFocusColor;
  } else {
    targetBgColor = activeBreakColor;
  }

  // Keyboard shortcuts listener
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Don't trigger if focus is in an input
      if (['INPUT', 'TEXTAREA'].includes((e.target as HTMLElement).tagName)) return;

      switch (e.code) {
        case 'Space':
          e.preventDefault();
          if (state.isRunning) pause();
          else start();
          break;
        case 'ArrowRight':
        case 'KeyN':
          e.preventDefault();
          skipNext();
          break;
        case 'ArrowLeft':
        case 'KeyP':
          e.preventDefault();
          skipPrevious();
          break;
        case 'KeyR':
          e.preventDefault();
          reset();
          break;
        case 'KeyM':
          e.preventDefault();
          toggleSound(!settings.soundEnabled);
          break;
        case 'KeyF':
          e.preventDefault();
          toggleFullscreen();
          break;
        case 'Escape':
          if (!document.fullscreenElement) {
            closeVisualizer();
          }
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [state.isRunning, settings.soundEnabled]);

  // Fullscreen change listener
  useEffect(() => {
    const handleFullscreenChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };
    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, []);

  // Circular progress calculations
  const radius = 130;
  const strokeWidth = 12;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference * (1 - progress);

  return (
    <div
      onClick={(e) => {
        // Toggle controls if clicking background
        if ((e.target as HTMLElement).closest('button')) return;
        setControlsVisible((v) => !v);
      }}
      className="fixed inset-0 z-50 flex flex-col items-center justify-center select-none cursor-default overflow-hidden transition-colors duration-700 ease-in-out text-white"
      style={{
        backgroundColor: targetBgColor,
      }}
    >
      {/* Subtle ambient lighting vignette overlay */}
      <div className="absolute inset-0 bg-radial from-white/10 via-black/15 to-black/40 pointer-events-none" />

      {/* Top Header Controls (Animated auto-hide) */}
      <div
        className={`absolute top-0 left-0 right-0 p-6 flex items-center justify-between z-20 transition-all duration-300 ${
          controlsVisible ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-8 pointer-events-none'
        }`}
      >
        <button
          onClick={closeVisualizer}
          className="p-3 rounded-2xl bg-black/25 hover:bg-black/40 backdrop-blur-md transition-all active:scale-95 flex items-center gap-2 text-sm font-semibold border border-white/10"
        >
          <ArrowLeft size={18} />
          <span>Exit Visualizer</span>
        </button>

        <div className="px-5 py-2 rounded-full bg-black/25 backdrop-blur-md text-xs font-bold tracking-wider uppercase border border-white/10">
          {state.preset.name}
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => toggleSound(!settings.soundEnabled)}
            className="p-3 rounded-2xl bg-black/25 hover:bg-black/40 backdrop-blur-md transition-all active:scale-95 border border-white/10"
            title={settings.soundEnabled ? 'Mute Alerts (M)' : 'Unmute Alerts (M)'}
          >
            {settings.soundEnabled ? <Volume2 size={18} /> : <VolumeX size={18} />}
          </button>
          <button
            onClick={toggleFullscreen}
            className="p-3 rounded-2xl bg-black/25 hover:bg-black/40 backdrop-blur-md transition-all active:scale-95 border border-white/10"
            title="Toggle Fullscreen (F)"
          >
            {isFullscreen ? <Minimize2 size={18} /> : <Maximize2 size={18} />}
          </button>
        </div>
      </div>

      {/* Main Focus Dial & Countdown */}
      <div className="relative z-10 flex flex-col items-center">
        {/* Phase Pill Badge */}
        <div className="mb-8 px-6 py-2.5 rounded-full bg-white/20 backdrop-blur-md border border-white/25 shadow-lg flex items-center gap-2.5">
          <Sparkles size={16} className="text-white" />
          <span className="font-extrabold text-sm tracking-widest uppercase">
            {currentPhase.name}
          </span>
        </div>

        {/* Circular SVG Timer Ring */}
        <div className="relative flex items-center justify-center">
          <svg width={320} height={320} className="transform -rotate-90">
            {/* Background Track */}
            <circle
              cx={160}
              cy={160}
              r={radius}
              stroke="currentColor"
              strokeWidth={strokeWidth}
              className="text-white/15 fill-none"
            />
            {/* Active Progress Arc */}
            <circle
              cx={160}
              cy={160}
              r={radius}
              stroke="white"
              strokeWidth={strokeWidth}
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              strokeLinecap="round"
              className="fill-none transition-all duration-300 ease-linear drop-shadow-[0_0_12px_rgba(255,255,255,0.4)]"
            />
          </svg>

          {/* Central Countdown Text */}
          <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
            <span className="font-mono-numbers text-7xl font-black tracking-tighter drop-shadow-md">
              {formattedTime}
            </span>
            <span className="text-xs font-bold tracking-widest text-white/75 mt-2 uppercase">
              {state.isRunning ? 'Active Flow' : state.isPaused ? 'Paused' : 'Ready'}
            </span>
          </div>
        </div>

        {/* Cycle Progress Tracker Pills */}
        <div className="mt-8 flex items-center gap-2">
          {Array.from({ length: state.preset.iterations }).map((_, idx) => {
            const cycleNum = idx + 1;
            const isDone = cycleNum < state.currentIteration;
            const isCurrent = cycleNum === state.currentIteration;

            return (
              <div
                key={idx}
                className={`h-2.5 rounded-full transition-all duration-300 ${
                  isDone
                    ? 'w-7 bg-white'
                    : isCurrent
                    ? 'w-10 bg-white shadow-lg'
                    : 'w-3 bg-white/30'
                }`}
                title={`Cycle ${cycleNum} of ${state.preset.iterations}`}
              />
            );
          })}
        </div>
        <span className="text-xs font-semibold text-white/70 mt-2">
          Cycle {state.currentIteration} of {state.preset.iterations}
        </span>
      </div>

      {/* Floating Bottom Control Bar (Animated auto-hide) */}
      <div
        className={`absolute bottom-8 z-20 transition-all duration-300 ${
          controlsVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8 pointer-events-none'
        }`}
      >
        <div className="flex items-center gap-4 px-6 py-3.5 rounded-full bg-black/35 backdrop-blur-xl border border-white/15 shadow-2xl">
          {/* Reset button */}
          <button
            onClick={reset}
            className="p-3 rounded-full hover:bg-white/15 active:scale-95 transition-all text-white/90"
            title="Reset (R)"
          >
            <RotateCcw size={22} />
          </button>

          {/* Skip Previous */}
          <button
            onClick={skipPrevious}
            className="p-3 rounded-full hover:bg-white/15 active:scale-95 transition-all text-white/90"
            title="Previous (P)"
          >
            <SkipBack size={24} />
          </button>

          {/* Big Play / Pause Main CTA */}
          <button
            onClick={() => {
              if (state.isRunning) pause();
              else start();
            }}
            className="w-16 h-16 rounded-full bg-white text-slate-900 shadow-xl flex items-center justify-center hover:scale-105 active:scale-95 transition-all"
            title="Play / Pause (Space)"
          >
            {state.isRunning ? (
              <Pause size={28} fill="currentColor" />
            ) : (
              <Play size={28} fill="currentColor" className="ml-1" />
            )}
          </button>

          {/* Skip Next */}
          <button
            onClick={skipNext}
            className="p-3 rounded-full hover:bg-white/15 active:scale-95 transition-all text-white/90"
            title="Next (N)"
          >
            <SkipForward size={24} />
          </button>

          {/* Keyboard tip hint */}
          <div className="hidden sm:block pl-2 border-l border-white/20 text-[10px] text-white/60 leading-tight">
            Space: Play/Pause<br />
            N/P: Next/Prev
          </div>
        </div>
      </div>

      {/* Completed State Celebration Overlay */}
      {state.isCompleted && (
        <div className="absolute inset-0 z-30 bg-slate-950/90 backdrop-blur-lg flex flex-col items-center justify-center p-8 text-center animate-in fade-in duration-300">
          <div className="w-20 h-20 rounded-3xl bg-amber-500/20 text-amber-400 flex items-center justify-center mb-6 neu-flat border border-amber-500/30">
            <Trophy size={42} />
          </div>
          <h2 className="text-3xl sm:text-4xl font-black mb-3">Routine Complete!</h2>
          <p className="text-slate-300 max-w-md text-sm sm:text-base mb-8">
            Outstanding session! You completed all {state.preset.iterations} cycles of{' '}
            <span className="font-bold text-white">{state.preset.name}</span>.
          </p>
          <div className="flex flex-col sm:flex-row gap-4">
            <button
              onClick={() => {
                reset();
                start();
              }}
              className="px-8 py-3.5 rounded-2xl bg-white text-slate-950 font-bold hover:bg-slate-100 transition-all flex items-center justify-center gap-2"
            >
              <RotateCcw size={18} />
              <span>Restart Routine</span>
            </button>
            <button
              onClick={closeVisualizer}
              className="px-8 py-3.5 rounded-2xl bg-white/15 text-white font-bold hover:bg-white/25 transition-all"
            >
              Return to Home
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

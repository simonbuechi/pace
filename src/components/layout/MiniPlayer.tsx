import { Play, Pause, Maximize2 } from 'lucide-react';
import { useTimer } from '../../context/TimerContext';
import { useSettings } from '../../context/SettingsContext';

export const MiniPlayer: React.FC = () => {
  const { state, currentPhase, formattedTime, openVisualizer, start, pause, isVisualizerOpen } =
    useTimer();
  const { activeFocusColor, activeBreakColor } = useSettings();

  const isVisible = (state.isRunning || state.isPaused) && !state.isCompleted && !isVisualizerOpen;

  if (!isVisible) return null;

  const isFocus = currentPhase.type === 'focus';
  const playerColor = isFocus ? activeFocusColor : activeBreakColor;

  return (
    <div className="fixed bottom-6 left-4 right-4 max-w-lg mx-auto z-40 animate-in slide-in-from-bottom-5 duration-300">
      <div
        onClick={openVisualizer}
        className="p-3.5 pr-4 rounded-3xl text-white shadow-2xl flex items-center justify-between gap-4 cursor-pointer hover:scale-[1.01] active:scale-[0.99] transition-all border border-white/20"
        style={{
          backgroundColor: playerColor,
          boxShadow: `0 14px 35px -5px ${playerColor}77`,
        }}
      >
        {/* Left Phase Info */}
        <div className="flex items-center gap-3">
          <img
            src="/logo.jpg"
            alt="Pace Amigo"
            className="w-10 h-10 rounded-2xl object-cover shrink-0 border border-white/30 shadow-sm"
          />
          <div>
            <div className="text-[11px] font-extrabold uppercase tracking-widest text-white/80">
              {currentPhase.name} • Cycle {state.currentIteration}/{state.preset.iterations}
            </div>
            <div className="text-xl font-black font-mono-numbers tracking-tight">
              {formattedTime}
            </div>
          </div>
        </div>

        {/* Controls */}
        <div className="flex items-center gap-2" onClick={(e) => e.stopPropagation()}>
          <button
            onClick={() => {
              if (state.isRunning) pause();
              else start();
            }}
            className="w-11 h-11 rounded-2xl bg-white text-slate-900 shadow-md flex items-center justify-center hover:scale-105 active:scale-95 transition-all"
            title={state.isRunning ? 'Pause' : 'Resume'}
          >
            {state.isRunning ? (
              <Pause size={20} fill="currentColor" />
            ) : (
              <Play size={20} fill="currentColor" className="ml-0.5" />
            )}
          </button>

          <button
            onClick={openVisualizer}
            className="p-2.5 rounded-2xl bg-white/20 hover:bg-white/30 text-white transition-all"
            title="Expand Fullscreen Visualizer"
          >
            <Maximize2 size={18} />
          </button>
        </div>
      </div>
    </div>
  );
};

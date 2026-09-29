import React, { useState } from 'react';
import {
  Play,
  Flame,
  Coffee,
  Repeat2,
  Sparkles,
  Plus,
  Minus,
  CheckCircle2,
  Timer as TimerIcon,
} from 'lucide-react';
import { useTimer } from '../../context/TimerContext';
import { useSettings } from '../../context/SettingsContext';
import { NeuCard } from '../common/NeuCard';
import { NeuButton } from '../common/NeuButton';
import { NeuSlider } from '../common/NeuSlider';
import type { RoutinePreset } from '../../types';

export const QuickStart: React.FC = () => {
  const { loadPreset } = useTimer();
  const { activeFocusColor, activeBreakColor } = useSettings();

  const [focusMinutes, setFocusMinutes] = useState(25);
  const [focusSeconds, setFocusSeconds] = useState(0);
  const [breakMinutes, setBreakMinutes] = useState(5);
  const [breakSeconds, setBreakSeconds] = useState(0);
  const [iterations, setIterations] = useState(4);

  const focusTotalSec = Math.max(5, focusMinutes * 60 + focusSeconds);
  const breakTotalSec = Math.max(5, breakMinutes * 60 + breakSeconds);
  const cycleTotalSec = focusTotalSec + breakTotalSec;
  const totalSeconds = cycleTotalSec * iterations;

  const formatDuration = (secs: number) => {
    const hrs = Math.floor(secs / 3600);
    const mins = Math.floor((secs % 3600) / 60);
    const s = secs % 60;
    if (hrs > 0) return `${hrs}h ${mins}m`;
    if (mins > 0) return `${mins}m ${s > 0 ? `${s}s` : ''}`.trim();
    return `${s}s`;
  };

  // Focus vs Break percentages
  const focusRatio = cycleTotalSec > 0 ? (focusTotalSec / cycleTotalSec) * 100 : 80;
  const breakRatio = 100 - focusRatio;

  // Estimated Finish Time
  const now = new Date();
  const finishTime = new Date(now.getTime() + totalSeconds * 1000);
  const formattedFinishTime = finishTime.toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
  });

  const handleAdjustFocus = (deltaMins: number, deltaSecs = 0) => {
    const nextTotal = Math.max(5, Math.min(720 * 60, focusTotalSec + deltaMins * 60 + deltaSecs));
    setFocusMinutes(Math.floor(nextTotal / 60));
    setFocusSeconds(nextTotal % 60);
  };

  const handleAdjustBreak = (deltaMins: number, deltaSecs = 0) => {
    const nextTotal = Math.max(5, Math.min(180 * 60, breakTotalSec + deltaMins * 60 + deltaSecs));
    setBreakMinutes(Math.floor(nextTotal / 60));
    setBreakSeconds(nextTotal % 60);
  };

  const handleStart = () => {
    const quickPreset: RoutinePreset = {
      id: `quick_${Date.now()}`,
      name: 'Quick Start Session',
      description: `${formatDuration(focusTotalSec)} focus • ${formatDuration(breakTotalSec)} break • ${iterations} rounds`,
      iterations,
      createdAt: new Date().toISOString(),
      phases: [
        {
          id: 'quick_p_focus',
          type: 'focus',
          name: 'Focus Interval',
          durationInSeconds: focusTotalSec,
        },
        {
          id: 'quick_p_break',
          type: 'shortBreak',
          name: 'Rest Interval',
          durationInSeconds: breakTotalSec,
        },
      ],
    };

    loadPreset(quickPreset, true);
  };

  return (
    <div className="space-y-8 pb-20">
      {/* Studio Top Header */}
      <div className="pb-3 border-b border-[var(--color-border-subtle)]">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-xs font-bold text-transparent bg-clip-text bg-gradient-to-r from-[#9123A6] to-[#D7195F] mb-2">
          <Sparkles size={13} className="text-[#D7195F]" />
          <span>SESSION STUDIO</span>
        </div>
        <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight">Quick Start</h1>
        <p className="text-sm text-[var(--color-text-muted)] mt-1">
          Specify custom duration for focus, break, and round iterations with live telemetry.
        </p>
      </div>

      {/* Main Studio Dual-Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Left Column: Live Session Monitor (Sticky Desktop Card) */}
        <div className="lg:col-span-5 lg:sticky lg:top-28 space-y-6">
          <NeuCard className="p-7 space-y-6">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] flex items-center gap-2">
                <TimerIcon size={16} className="text-[#D7195F]" />
                <span>Session Preview</span>
              </span>
              <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 font-mono-numbers">
                {iterations} {iterations === 1 ? 'Cycle' : 'Cycles'}
              </span>
            </div>

            {/* Total Duration Readout */}
            <div className="text-center py-5 px-4 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/60 dark:border-slate-800">
              <span className="text-xs font-bold uppercase tracking-widest text-[var(--color-text-muted)] block">
                Total Planned Session
              </span>
              <div className="text-4xl sm:text-5xl font-black font-mono-numbers tracking-tight mt-1 text-transparent bg-clip-text bg-gradient-to-r from-[#9123A6] to-[#D7195F]">
                {formatDuration(totalSeconds)}
              </div>
              <span className="text-xs font-medium text-[var(--color-text-muted)] mt-1 block">
                Finishes around <span className="font-bold text-[var(--color-text-main)]">{formattedFinishTime}</span>
              </span>
            </div>

            {/* Interval Breakdown Bar */}
            <div className="space-y-2">
              <div className="flex justify-between text-xs font-bold">
                <span className="flex items-center gap-1.5" style={{ color: activeFocusColor }}>
                  <Flame size={14} /> Focus: {Math.round(focusRatio)}% ({formatDuration(focusTotalSec * iterations)})
                </span>
                <span className="flex items-center gap-1.5" style={{ color: activeBreakColor }}>
                  <Coffee size={14} /> Rest: {Math.round(breakRatio)}% ({formatDuration(breakTotalSec * iterations)})
                </span>
              </div>

              {/* Progress bar visualizing phase ratio */}
              <div className="w-full h-3 rounded-full overflow-hidden flex bg-slate-100 dark:bg-slate-800">
                <div
                  className="h-full transition-all duration-300"
                  style={{ width: `${focusRatio}%`, backgroundColor: activeFocusColor }}
                  title={`Focus: ${formatDuration(focusTotalSec)}`}
                />
                <div
                  className="h-full transition-all duration-300"
                  style={{ width: `${breakRatio}%`, backgroundColor: activeBreakColor }}
                  title={`Rest: ${formatDuration(breakTotalSec)}`}
                />
              </div>
            </div>

            {/* Sequence Summary Strip (Clean & peaceful, no matrix of 32 shadowed boxes) */}
            <div className="p-3.5 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/60 dark:border-slate-800 flex items-center justify-between text-xs">
              <span className="text-[var(--color-text-muted)] font-medium">Routine Pattern:</span>
              <span className="font-bold text-[var(--color-text-main)]">
                {iterations} × ({formatDuration(focusTotalSec)} focus + {formatDuration(breakTotalSec)} rest)
              </span>
            </div>

            {/* Start CTA */}
            <div className="pt-2">
              <NeuButton
                variant="primary"
                size="lg"
                onClick={handleStart}
                className="w-full py-4 text-base font-extrabold flex items-center justify-center gap-3 rounded-2xl group"
              >
                <Play size={20} fill="currentColor" className="group-hover:scale-110 transition-transform" />
                <span>Launch Session</span>
              </NeuButton>
              <div className="text-center mt-2.5 text-[11px] text-[var(--color-text-muted)] flex items-center justify-center gap-1.5">
                <CheckCircle2 size={13} className="text-emerald-500" />
                <span>Distraction-free fullscreen visualizer ready</span>
              </div>
            </div>
          </NeuCard>
        </div>

        {/* Right Column: Clean Numeric Inputs Studio */}
        <div className="lg:col-span-7 space-y-6">
          {/* Focus Duration Card */}
          <NeuCard className="p-7 space-y-5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3.5">
                <div
                  className="w-11 h-11 rounded-2xl flex items-center justify-center text-white shrink-0 shadow-sm"
                  style={{ backgroundColor: activeFocusColor }}
                >
                  <Flame size={22} />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg">Focus Duration</h3>
                  <p className="text-xs text-[var(--color-text-muted)]">Concentrated deep work interval</p>
                </div>
              </div>

              <div className="text-sm font-black font-mono-numbers px-3 py-1 rounded-xl bg-slate-100 dark:bg-slate-800" style={{ color: activeFocusColor }}>
                {focusMinutes}m {focusSeconds > 0 ? `${focusSeconds}s` : ''}
              </div>
            </div>

            {/* Clean Numeric Input Field (Calm layout with single clear controls) */}
            <div className="p-5 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/60 dark:border-slate-800">
              <div className="flex items-center justify-center gap-4 sm:gap-6">
                {/* Minutes Input */}
                <div className="flex flex-col items-center">
                  <div className="flex items-center gap-1.5">
                    <button
                      type="button"
                      onClick={() => handleAdjustFocus(-1, 0)}
                      className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                    >
                      <Minus size={15} />
                    </button>
                    <input
                      type="number"
                      min={0}
                      max={720}
                      value={focusMinutes}
                      onChange={(e) => {
                        const val = parseInt(e.target.value, 10);
                        setFocusMinutes(isNaN(val) ? 0 : Math.max(0, Math.min(720, val)));
                      }}
                      className="w-20 sm:w-24 py-2.5 text-center text-3xl font-black font-mono-numbers rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-main)] focus:outline-none focus:ring-2 focus:ring-[var(--color-focus)] [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                    />
                    <button
                      type="button"
                      onClick={() => handleAdjustFocus(1, 0)}
                      className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                    >
                      <Plus size={15} />
                    </button>
                  </div>
                  <span className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] mt-2">
                    Minutes
                  </span>
                </div>

                <div className="text-2xl font-black text-[var(--color-text-muted)] opacity-40 pb-5">:</div>

                {/* Seconds Input */}
                <div className="flex flex-col items-center">
                  <div className="flex items-center gap-1.5">
                    <button
                      type="button"
                      onClick={() => handleAdjustFocus(0, -15)}
                      className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                      title="-15 sec"
                    >
                      <Minus size={15} />
                    </button>
                    <input
                      type="number"
                      min={0}
                      max={59}
                      value={focusSeconds}
                      onChange={(e) => {
                        const val = parseInt(e.target.value, 10);
                        setFocusSeconds(isNaN(val) ? 0 : Math.max(0, Math.min(59, val)));
                      }}
                      className="w-20 sm:w-24 py-2.5 text-center text-3xl font-black font-mono-numbers rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-main)] focus:outline-none focus:ring-2 focus:ring-[var(--color-focus)] [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                    />
                    <button
                      type="button"
                      onClick={() => handleAdjustFocus(0, 15)}
                      className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                      title="+15 sec"
                    >
                      <Plus size={15} />
                    </button>
                  </div>
                  <span className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] mt-2">
                    Seconds (0-59)
                  </span>
                </div>
              </div>

              {/* Quick Stepper Row */}
              <div className="flex items-center justify-center gap-2 pt-4 mt-4 border-t border-slate-200/60 dark:border-slate-800">
                <button
                  type="button"
                  onClick={() => handleAdjustFocus(-5, 0)}
                  className="px-2.5 py-1 rounded-lg text-xs font-bold bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  -5m
                </button>
                <button
                  type="button"
                  onClick={() => handleAdjustFocus(-1, 0)}
                  className="px-2.5 py-1 rounded-lg text-xs font-bold bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  -1m
                </button>
                <button
                  type="button"
                  onClick={() => handleAdjustFocus(1, 0)}
                  className="px-2.5 py-1 rounded-lg text-xs font-bold bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  +1m
                </button>
                <button
                  type="button"
                  onClick={() => handleAdjustFocus(5, 0)}
                  className="px-2.5 py-1 rounded-lg text-xs font-bold bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  +5m
                </button>
              </div>
            </div>

            {/* Slider */}
            <div className="space-y-1.5 pt-1">
              <div className="flex justify-between text-xs text-[var(--color-text-muted)] font-semibold">
                <span>0 min</span>
                <span>30 min</span>
                <span>60 min</span>
                <span>120 min</span>
              </div>
              <NeuSlider
                min={0}
                max={120}
                value={focusMinutes}
                onChange={(val) => setFocusMinutes(val)}
                accentColor={activeFocusColor}
              />
            </div>
          </NeuCard>

          {/* Break Duration Card */}
          <NeuCard className="p-7 space-y-5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3.5">
                <div
                  className="w-11 h-11 rounded-2xl flex items-center justify-center text-white shrink-0 shadow-sm"
                  style={{ backgroundColor: activeBreakColor }}
                >
                  <Coffee size={22} />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg">Break Duration</h3>
                  <p className="text-xs text-[var(--color-text-muted)]">Recovery and physical reset</p>
                </div>
              </div>

              <div className="text-sm font-black font-mono-numbers px-3 py-1 rounded-xl bg-slate-100 dark:bg-slate-800" style={{ color: activeBreakColor }}>
                {breakMinutes}m {breakSeconds > 0 ? `${breakSeconds}s` : ''}
              </div>
            </div>

            {/* Clean Numeric Input Field */}
            <div className="p-5 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/60 dark:border-slate-800">
              <div className="flex items-center justify-center gap-4 sm:gap-6">
                {/* Minutes Input */}
                <div className="flex flex-col items-center">
                  <div className="flex items-center gap-1.5">
                    <button
                      type="button"
                      onClick={() => handleAdjustBreak(-1, 0)}
                      className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                    >
                      <Minus size={15} />
                    </button>
                    <input
                      type="number"
                      min={0}
                      max={180}
                      value={breakMinutes}
                      onChange={(e) => {
                        const val = parseInt(e.target.value, 10);
                        setBreakMinutes(isNaN(val) ? 0 : Math.max(0, Math.min(180, val)));
                      }}
                      className="w-20 sm:w-24 py-2.5 text-center text-3xl font-black font-mono-numbers rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-main)] focus:outline-none focus:ring-2 focus:ring-[var(--color-break)] [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                    />
                    <button
                      type="button"
                      onClick={() => handleAdjustBreak(1, 0)}
                      className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                    >
                      <Plus size={15} />
                    </button>
                  </div>
                  <span className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] mt-2">
                    Minutes
                  </span>
                </div>

                <div className="text-2xl font-black text-[var(--color-text-muted)] opacity-40 pb-5">:</div>

                {/* Seconds Input */}
                <div className="flex flex-col items-center">
                  <div className="flex items-center gap-1.5">
                    <button
                      type="button"
                      onClick={() => handleAdjustBreak(0, -15)}
                      className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                      title="-15 sec"
                    >
                      <Minus size={15} />
                    </button>
                    <input
                      type="number"
                      min={0}
                      max={59}
                      value={breakSeconds}
                      onChange={(e) => {
                        const val = parseInt(e.target.value, 10);
                        setBreakSeconds(isNaN(val) ? 0 : Math.max(0, Math.min(59, val)));
                      }}
                      className="w-20 sm:w-24 py-2.5 text-center text-3xl font-black font-mono-numbers rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-main)] focus:outline-none focus:ring-2 focus:ring-[var(--color-break)] [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                    />
                    <button
                      type="button"
                      onClick={() => handleAdjustBreak(0, 15)}
                      className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                      title="+15 sec"
                    >
                      <Plus size={15} />
                    </button>
                  </div>
                  <span className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] mt-2">
                    Seconds (0-59)
                  </span>
                </div>
              </div>

              {/* Quick Stepper Row */}
              <div className="flex items-center justify-center gap-2 pt-4 mt-4 border-t border-slate-200/60 dark:border-slate-800">
                <button
                  type="button"
                  onClick={() => handleAdjustBreak(-5, 0)}
                  className="px-2.5 py-1 rounded-lg text-xs font-bold bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  -5m
                </button>
                <button
                  type="button"
                  onClick={() => handleAdjustBreak(-1, 0)}
                  className="px-2.5 py-1 rounded-lg text-xs font-bold bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  -1m
                </button>
                <button
                  type="button"
                  onClick={() => handleAdjustBreak(1, 0)}
                  className="px-2.5 py-1 rounded-lg text-xs font-bold bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  +1m
                </button>
                <button
                  type="button"
                  onClick={() => handleAdjustBreak(5, 0)}
                  className="px-2.5 py-1 rounded-lg text-xs font-bold bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  +5m
                </button>
              </div>
            </div>

            {/* Slider */}
            <div className="space-y-1.5 pt-1">
              <div className="flex justify-between text-xs text-[var(--color-text-muted)] font-semibold">
                <span>0 min</span>
                <span>15 min</span>
                <span>30 min</span>
                <span>45 min</span>
              </div>
              <NeuSlider
                min={0}
                max={45}
                value={breakMinutes}
                onChange={(val) => setBreakMinutes(val)}
                accentColor={activeBreakColor}
              />
            </div>
          </NeuCard>

          {/* Iteration Cycles / Rounds Card */}
          <NeuCard className="p-7 space-y-5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3.5">
                <div className="w-11 h-11 rounded-2xl flex items-center justify-center text-white shrink-0 bg-slate-700 shadow-sm">
                  <Repeat2 size={22} />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg">Interval Cycles</h3>
                  <p className="text-xs text-[var(--color-text-muted)]">Number of rounds to repeat</p>
                </div>
              </div>

              {/* Direct Numeric Input with Stepper */}
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setIterations(Math.max(1, iterations - 1))}
                  className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center font-bold text-base text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  -
                </button>
                <div className="flex items-center gap-1.5 px-3 py-1 rounded-xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/60 dark:border-slate-800">
                  <input
                    type="number"
                    min={1}
                    max={99}
                    value={iterations}
                    onChange={(e) => {
                      const val = parseInt(e.target.value, 10);
                      setIterations(isNaN(val) ? 1 : Math.max(1, Math.min(99, val)));
                    }}
                    className="w-14 py-1 text-center text-2xl font-black font-mono-numbers bg-transparent border-none text-[var(--color-text-main)] focus:outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                  />
                  <span className="text-xs font-bold text-[var(--color-text-muted)] pr-1">
                    {iterations === 1 ? 'round' : 'rounds'}
                  </span>
                </div>
                <button
                  type="button"
                  onClick={() => setIterations(Math.min(99, iterations + 1))}
                  className="w-9 h-9 rounded-xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center font-bold text-base text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                >
                  +
                </button>
              </div>
            </div>

            {/* Slider */}
            <div className="space-y-1.5 pt-1">
              <div className="flex justify-between text-xs text-[var(--color-text-muted)] font-semibold">
                <span>1 round</span>
                <span>10 rounds</span>
                <span>25 rounds</span>
                <span>50 rounds</span>
              </div>
              <NeuSlider
                min={1}
                max={50}
                value={Math.min(50, iterations)}
                onChange={(val) => setIterations(val)}
                accentColor="var(--color-focus)"
              />
            </div>
          </NeuCard>
        </div>
      </div>
    </div>
  );
};

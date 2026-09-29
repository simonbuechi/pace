import React, { useState } from 'react';
import {
  Plus,
  Trash2,
  ArrowUp,
  ArrowDown,
  Save,
  ArrowLeft,
  Layers,
  Sparkles,
  Clock,
  Repeat2,
  Flame,
  Coffee,
  Activity,
  Check,
} from 'lucide-react';
import type { IntervalPhase, IntervalPhaseType, RoutinePreset } from '../../types';
import { NeuCard } from '../common/NeuCard';
import { NeuButton } from '../common/NeuButton';
import { NeuSlider } from '../common/NeuSlider';
import { usePresets } from '../../context/PresetsContext';
import { useSettings } from '../../context/SettingsContext';

interface PresetEditorProps {
  initialPreset?: RoutinePreset | null;
  onClose: () => void;
}

export const PresetEditor: React.FC<PresetEditorProps> = ({ initialPreset, onClose }) => {
  const { savePreset } = usePresets();
  const { activeFocusColor, activeBreakColor } = useSettings();

  const [name, setName] = useState(initialPreset?.name || '');
  const [description, setDescription] = useState(initialPreset?.description || '');
  const [iterations, setIterations] = useState(initialPreset?.iterations || 3);
  const [phases, setPhases] = useState<IntervalPhase[]>(() => {
    if (initialPreset?.phases?.length) {
      return [...initialPreset.phases];
    }
    return [
      {
        id: 'phase_1',
        type: 'focus',
        name: 'Deep Focus Sprint',
        durationInSeconds: 25 * 60,
      },
      {
        id: 'phase_2',
        type: 'shortBreak',
        name: 'Rest & Recovery',
        durationInSeconds: 5 * 60,
      },
    ];
  });

  // Calculate sequence telemetry
  const cycleSeconds = phases.reduce((acc, p) => acc + p.durationInSeconds, 0);
  const totalSeconds = cycleSeconds * iterations;
  const focusSeconds = phases
    .filter((p) => p.type === 'focus')
    .reduce((acc, p) => acc + p.durationInSeconds, 0) * iterations;
  const breakSeconds = totalSeconds - focusSeconds;

  const formatDuration = (secs: number) => {
    const hrs = Math.floor(secs / 3600);
    const mins = Math.floor((secs % 3600) / 60);
    const s = secs % 60;
    if (hrs > 0) return `${hrs}h ${mins}m`;
    if (mins > 0) return `${mins}m ${s > 0 ? `${s}s` : ''}`;
    return `${s}s`;
  };

  const getEstimatedEndTime = () => {
    const finishDate = new Date(Date.now() + totalSeconds * 1000);
    return finishDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const handleAddPhase = (type: IntervalPhaseType = 'focus', durationMins = 15, nameText?: string) => {
    const defaultName =
      nameText ||
      (type === 'focus'
        ? `Focus Phase ${phases.filter((p) => p.type === 'focus').length + 1}`
        : type === 'shortBreak'
        ? 'Rest Recovery'
        : 'Active Drill');

    const newPhase: IntervalPhase = {
      id: `p_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
      type,
      name: defaultName,
      durationInSeconds: durationMins * 60,
    };
    setPhases([...phases, newPhase]);
  };

  const handleUpdatePhase = (index: number, updates: Partial<IntervalPhase>) => {
    setPhases((prev) => {
      const updated = [...prev];
      updated[index] = { ...updated[index], ...updates };
      return updated;
    });
  };

  const handleAdjustPhaseDuration = (index: number, deltaMinutes: number) => {
    setPhases((prev) => {
      const updated = [...prev];
      const cur = updated[index].durationInSeconds;
      const next = Math.max(30, Math.min(180 * 60, cur + deltaMinutes * 60));
      updated[index] = { ...updated[index], durationInSeconds: next };
      return updated;
    });
  };

  const handleRemovePhase = (index: number) => {
    if (phases.length <= 1) return;
    setPhases(phases.filter((_, i) => i !== index));
  };

  const handleMovePhase = (index: number, direction: 'up' | 'down') => {
    const targetIndex = direction === 'up' ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= phases.length) return;

    setPhases((prev) => {
      const copy = [...prev];
      const temp = copy[index];
      copy[index] = copy[targetIndex];
      copy[targetIndex] = temp;
      return copy;
    });
  };

  const handleSave = () => {
    if (!name.trim()) return;

    const preset: RoutinePreset = {
      id: initialPreset?.id || `preset_${Date.now()}`,
      name: name.trim(),
      description: description.trim(),
      iterations,
      phases,
      isCustomSequence: true,
      createdAt: initialPreset?.createdAt || new Date().toISOString(),
    };

    savePreset(preset);
    onClose();
  };

  return (
    <div className="space-y-8 pb-24">
      {/* Studio Action Top Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-[var(--color-border-subtle)]">
        <div className="flex items-center gap-3">
          <button
            onClick={onClose}
            className="p-2.5 rounded-2xl bg-slate-100 dark:bg-slate-800/80 border border-slate-200/60 dark:border-slate-700/60 hover:bg-slate-200 dark:hover:bg-slate-700 flex items-center gap-2 text-sm font-bold text-[var(--color-text-muted)] transition-all hover:text-[var(--color-text-main)]"
          >
            <ArrowLeft size={18} />
            <span className="hidden sm:inline">Back to Routines</span>
          </button>
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-0.5 rounded-full bg-slate-100 dark:bg-slate-800 text-[11px] font-bold text-[#9123A6] dark:text-[#D7195F] mb-1">
              <Sparkles size={12} className="text-[#D7195F]" />
              <span>{initialPreset ? 'ROUTINE STUDIO' : 'NEW WORKFLOW BUILDER'}</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
              {initialPreset ? `Edit "${initialPreset.name}"` : 'Create Custom Routine'}
            </h1>
          </div>
        </div>

        <div className="flex items-center gap-3 self-end sm:self-center">
          <NeuButton size="sm" variant="subtle" onClick={onClose}>
            Cancel
          </NeuButton>
          <NeuButton
            variant="primary"
            size="md"
            onClick={handleSave}
            disabled={!name.trim()}
            className="flex items-center gap-2 px-6"
          >
            <Save size={18} />
            <span>Save Routine</span>
          </NeuButton>
        </div>
      </div>

      {/* 2-Column Desktop Grid Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Left Sticky Column: Routine Blueprint & Telemetry (5 cols) */}
        <div className="lg:col-span-5 space-y-6 lg:sticky lg:top-24">
          {/* Blueprint Card */}
          <NeuCard className="space-y-5 p-6">
            <div className="flex items-center gap-2 pb-2 border-b border-[var(--color-border-subtle)]">
              <Layers size={18} className="text-[var(--color-focus)]" />
              <h2 className="font-extrabold text-base">Routine Blueprint</h2>
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] mb-2">
                Routine Title <span className="text-[#D7195F]">*</span>
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. Deep Coding Sprint, Tabata HIIT, Study Session"
                className="w-full px-4 py-3 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/70 dark:border-slate-800 text-[var(--color-text-main)] font-bold text-sm focus:outline-none focus:ring-2 focus:ring-[var(--color-focus)]"
              />
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] mb-2">
                Description & Notes
              </label>
              <textarea
                rows={2}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Key goals, target activities, or workout details..."
                className="w-full px-4 py-3 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/70 dark:border-slate-800 text-[var(--color-text-main)] text-sm focus:outline-none focus:ring-2 focus:ring-[var(--color-focus)] resize-none"
              />
            </div>

            {/* Repeat Cycles Stepper & Number Input */}
            <div>
              <div className="flex justify-between items-center mb-2">
                <label className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] flex items-center gap-1.5">
                  <Repeat2 size={14} className="text-[var(--color-focus)]" />
                  <span>Repeat Cycles</span>
                </label>
                <div className="flex items-center gap-1 px-2.5 py-0.5 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-200/60 dark:border-slate-700/60">
                  <input
                    type="number"
                    min={1}
                    max={99}
                    value={iterations}
                    onChange={(e) => {
                      const val = parseInt(e.target.value, 10);
                      setIterations(isNaN(val) ? 1 : Math.max(1, Math.min(99, val)));
                    }}
                    className="w-12 text-center font-black font-mono-numbers text-sm bg-transparent border-none text-[var(--color-focus)] focus:outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                  />
                  <span className="text-[10px] font-bold text-[var(--color-text-muted)] pr-1">
                    {iterations === 1 ? 'round' : 'rounds'}
                  </span>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <button
                  type="button"
                  onClick={() => setIterations(Math.max(1, iterations - 1))}
                  className="w-10 h-10 rounded-2xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center font-bold text-lg transition-colors"
                >
                  -
                </button>
                <div className="flex-1">
                  <NeuSlider
                    min={1}
                    max={24}
                    value={Math.min(24, iterations)}
                    onChange={(val) => setIterations(val)}
                    accentColor={activeFocusColor}
                  />
                </div>
                <button
                  type="button"
                  onClick={() => setIterations(Math.min(99, iterations + 1))}
                  className="w-10 h-10 rounded-2xl bg-white dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 active:scale-95 flex items-center justify-center font-bold text-lg transition-colors"
                >
                  +
                </button>
              </div>
            </div>
          </NeuCard>

          {/* Routine Telemetry Monitor */}
          <NeuCard className="p-6 space-y-4">
            <span className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] block">
              Session Telemetry
            </span>

            <div className="grid grid-cols-2 gap-3">
              <div className="p-3.5 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/60 dark:border-slate-800">
                <div className="flex items-center gap-1.5 text-xs text-[var(--color-text-muted)] font-semibold mb-1">
                  <Clock size={13} />
                  <span>Total Duration</span>
                </div>
                <div className="text-xl font-black font-mono-numbers text-[var(--color-text-main)]">
                  {formatDuration(totalSeconds)}
                </div>
              </div>

              <div className="p-3.5 rounded-2xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200/60 dark:border-slate-800">
                <div className="flex items-center gap-1.5 text-xs text-[var(--color-text-muted)] font-semibold mb-1">
                  <Activity size={13} />
                  <span>Estimated Finish</span>
                </div>
                <div className="text-xl font-black font-mono-numbers text-emerald-600 dark:text-emerald-400">
                  {getEstimatedEndTime()}
                </div>
              </div>
            </div>

            {/* Visual ratio bar */}
            <div className="space-y-2 pt-1">
              <div className="flex justify-between text-xs font-bold text-[var(--color-text-muted)]">
                <span className="flex items-center gap-1">
                  <span className="w-2 h-2 rounded-full" style={{ backgroundColor: activeFocusColor }} />
                  Focus: {formatDuration(focusSeconds)}
                </span>
                <span className="flex items-center gap-1">
                  <span className="w-2 h-2 rounded-full" style={{ backgroundColor: activeBreakColor }} />
                  Break: {formatDuration(breakSeconds)}
                </span>
              </div>
              <div className="h-3 rounded-full overflow-hidden flex bg-slate-100 dark:bg-slate-800">
                <div
                  className="h-full transition-all duration-300"
                  style={{
                    width: `${totalSeconds > 0 ? (focusSeconds / totalSeconds) * 100 : 50}%`,
                    backgroundColor: activeFocusColor,
                  }}
                />
                <div
                  className="h-full transition-all duration-300"
                  style={{
                    width: `${totalSeconds > 0 ? (breakSeconds / totalSeconds) * 100 : 50}%`,
                    backgroundColor: activeBreakColor,
                  }}
                />
              </div>
            </div>

            <NeuButton
              variant="primary"
              size="md"
              onClick={handleSave}
              disabled={!name.trim()}
              className="w-full py-3.5 font-bold flex items-center justify-center gap-2 mt-2"
            >
              <Check size={18} />
              <span>Save & Publish Routine</span>
            </NeuButton>
          </NeuCard>
        </div>

        {/* Right Column: Interval Sequence Editor (7 cols) */}
        <div className="lg:col-span-7 space-y-5">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-xl font-extrabold tracking-tight">Interval Sequence</h2>
                <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-[var(--color-focus)]/10 text-[var(--color-focus)]">
                  {phases.length} {phases.length === 1 ? 'Step' : 'Steps'}
                </span>
              </div>
              <p className="text-xs text-[var(--color-text-muted)] mt-0.5">
                Customize the phases executed during each cycle.
              </p>
            </div>

            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => handleAddPhase('focus', 25, 'Focus Sprint')}
                className="px-3 py-1.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700/60 text-xs font-bold flex items-center gap-1.5 transition-colors text-[var(--color-focus)]"
              >
                <Flame size={14} />
                <span>+ 25m Focus</span>
              </button>
              <button
                type="button"
                onClick={() => handleAddPhase('shortBreak', 5, 'Short Break')}
                className="px-3 py-1.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700/60 text-xs font-bold flex items-center gap-1.5 transition-colors text-[var(--color-break)]"
              >
                <Coffee size={14} />
                <span>+ 5m Break</span>
              </button>
            </div>
          </div>

          {/* Phase Cards */}
          <div className="space-y-4">
            {phases.map((phase, idx) => {
              const minutes = Math.floor(phase.durationInSeconds / 60);
              const seconds = phase.durationInSeconds % 60;

              const isFocus = phase.type === 'focus';
              const isBreak = phase.type === 'shortBreak' || phase.type === 'longBreak';
              const badgeColor = isFocus
                ? activeFocusColor
                : isBreak
                ? activeBreakColor
                : '#EAB308';

              return (
                <NeuCard key={phase.id} className="p-5 space-y-4">
                  {/* Phase Row Header */}
                  <div className="flex items-center justify-between gap-3">
                    <div className="flex items-center gap-3 flex-1">
                      <div
                        className="w-9 h-9 rounded-xl flex items-center justify-center text-white text-xs font-extrabold shrink-0 shadow-sm"
                        style={{ backgroundColor: badgeColor }}
                      >
                        {idx + 1}
                      </div>
                      <input
                        type="text"
                        value={phase.name}
                        onChange={(e) => handleUpdatePhase(idx, { name: e.target.value })}
                        className="font-extrabold text-base bg-transparent border border-transparent focus:border-slate-200 dark:focus:border-slate-700 focus:bg-slate-50 dark:focus:bg-slate-800 focus:outline-none flex-1 text-[var(--color-text-main)] px-2 py-1 rounded-xl transition-all"
                        placeholder="Phase title..."
                      />
                    </div>

                    {/* Step Reorder & Delete */}
                    <div className="flex items-center gap-1 shrink-0">
                      <button
                        onClick={() => handleMovePhase(idx, 'up')}
                        disabled={idx === 0}
                        className="p-2 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700/60 disabled:opacity-30 disabled:pointer-events-none transition-colors"
                        title="Move Up"
                      >
                        <ArrowUp size={15} />
                      </button>
                      <button
                        onClick={() => handleMovePhase(idx, 'down')}
                        disabled={idx === phases.length - 1}
                        className="p-2 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700/60 disabled:opacity-30 disabled:pointer-events-none transition-colors"
                        title="Move Down"
                      >
                        <ArrowDown size={15} />
                      </button>
                      <button
                        onClick={() => handleRemovePhase(idx)}
                        disabled={phases.length <= 1}
                        className="p-2 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700/60 text-rose-500 disabled:opacity-30 disabled:pointer-events-none ml-1 transition-colors"
                        title="Remove Phase"
                      >
                        <Trash2 size={15} />
                      </button>
                    </div>
                  </div>

                  {/* Phase Type Pills */}
                  <div className="flex items-center gap-2">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[var(--color-text-muted)] mr-1">
                      Phase Type:
                    </span>
                    {(['focus', 'shortBreak', 'custom'] as IntervalPhaseType[]).map((type) => {
                      const isActive = phase.type === type;
                      return (
                        <button
                          key={type}
                          type="button"
                          onClick={() => {
                            const defaultName =
                              type === 'focus'
                                ? 'Focus Sprint'
                                : type === 'shortBreak'
                                ? 'Recovery Break'
                                : 'Custom Drill';
                            handleUpdatePhase(idx, {
                              type,
                              name:
                                phase.name.startsWith('Focus') ||
                                phase.name.startsWith('Rest') ||
                                phase.name.startsWith('Recovery') ||
                                phase.name.startsWith('Phase')
                                  ? defaultName
                                  : phase.name,
                            });
                          }}
                          className={`px-3 py-1 rounded-xl text-xs font-bold transition-all ${
                            isActive
                              ? 'text-white shadow-sm'
                              : 'bg-slate-100 dark:bg-slate-800 text-[var(--color-text-muted)] hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700/60'
                          }`}
                          style={{
                            backgroundColor: isActive
                              ? type === 'focus'
                                ? activeFocusColor
                                : type === 'shortBreak'
                                ? activeBreakColor
                                : '#EAB308'
                              : undefined,
                          }}
                        >
                          {type === 'focus' ? 'Focus' : type === 'shortBreak' ? 'Break' : 'Custom'}
                        </button>
                      );
                    })}
                  </div>

                  {/* Duration Inputs & Steppers */}
                  <div className="space-y-3 pt-2 border-t border-[var(--color-border-subtle)]">
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs font-bold">
                      <span className="text-[var(--color-text-muted)]">Phase Duration</span>

                      {/* Minutes and Seconds Direct Number Inputs */}
                      <div className="flex items-center gap-3">
                        <div className="flex items-center gap-1.5 px-3 py-1 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-200/60 dark:border-slate-700/60">
                          <input
                            type="number"
                            min={0}
                            max={360}
                            value={minutes}
                            onChange={(e) => {
                              const val = parseInt(e.target.value, 10);
                              const m = isNaN(val) ? 0 : Math.max(0, Math.min(360, val));
                              handleUpdatePhase(idx, { durationInSeconds: Math.max(5, m * 60 + seconds) });
                            }}
                            className="w-12 text-center font-black font-mono-numbers text-sm bg-transparent border-none text-[var(--color-text-main)] focus:outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                          />
                          <span className="text-[11px] font-bold text-[var(--color-text-muted)]">min</span>
                        </div>

                        <span className="font-bold text-[var(--color-text-muted)]">:</span>

                        <div className="flex items-center gap-1.5 px-3 py-1 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-200/60 dark:border-slate-700/60">
                          <input
                            type="number"
                            min={0}
                            max={59}
                            value={seconds}
                            onChange={(e) => {
                              const val = parseInt(e.target.value, 10);
                              const s = isNaN(val) ? 0 : Math.max(0, Math.min(59, val));
                              handleUpdatePhase(idx, { durationInSeconds: Math.max(5, minutes * 60 + s) });
                            }}
                            className="w-12 text-center font-black font-mono-numbers text-sm bg-transparent border-none text-[var(--color-text-main)] focus:outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                          />
                          <span className="text-[11px] font-bold text-[var(--color-text-muted)]">sec</span>
                        </div>

                        {/* Quick stepper buttons */}
                        <div className="flex items-center gap-1 ml-1">
                          <button
                            type="button"
                            onClick={() => handleAdjustPhaseDuration(idx, -1)}
                            className="px-2 py-1 rounded-lg text-[10px] font-bold bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700/60 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                            title="Subtract 1 minute"
                          >
                            -1m
                          </button>
                          <button
                            type="button"
                            onClick={() => handleAdjustPhaseDuration(idx, 1)}
                            className="px-2 py-1 rounded-lg text-[10px] font-bold bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700/60 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors"
                            title="Add 1 minute"
                          >
                            +1m
                          </button>
                        </div>
                      </div>
                    </div>

                    <NeuSlider
                      min={0}
                      max={90}
                      value={minutes}
                      onChange={(val) =>
                        handleUpdatePhase(idx, { durationInSeconds: Math.max(5, val * 60 + seconds) })
                      }
                      accentColor={badgeColor}
                    />
                  </div>
                </NeuCard>
              );
            })}
          </div>

          {/* Add Step Card */}
          <div className="pt-2">
            <button
              type="button"
              onClick={() => handleAddPhase('focus', 15)}
              className="w-full py-4 rounded-3xl bg-slate-50/50 dark:bg-slate-900/30 hover:bg-slate-100 dark:hover:bg-slate-800/50 border-2 border-dashed border-slate-200 dark:border-slate-800 flex items-center justify-center gap-2 text-sm font-bold text-[var(--color-text-muted)] hover:text-[var(--color-focus)] transition-all group"
            >
              <div className="w-8 h-8 rounded-full bg-[var(--color-focus)]/10 flex items-center justify-center text-[var(--color-focus)] group-hover:scale-110 transition-transform">
                <Plus size={16} />
              </div>
              <span>Add Another Interval Step</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};


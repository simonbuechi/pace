import React, { useState } from 'react';
import {
  Play,
  Plus,
  Clock,
  Repeat2,
  Layers,
  MoreVertical,
  Edit2,
  Copy,
  Trash2,
  Sparkles,
  Search,
  History,
} from 'lucide-react';
import { usePresets } from '../../context/PresetsContext';
import { useTimer } from '../../context/TimerContext';
import { useSettings } from '../../context/SettingsContext';
import type { RoutinePreset } from '../../types';
import { NeuCard } from '../common/NeuCard';
import { NeuButton } from '../common/NeuButton';
import { PresetEditor } from './PresetEditor';
import { RoutineLogsModal } from './RoutineLogsModal';

export const PresetList: React.FC = () => {
  const { presets, deletePreset, duplicatePreset, getLogsForPreset } = usePresets();
  const { loadPreset } = useTimer();
  const { activeFocusColor, activeBreakColor } = useSettings();

  const [editingPreset, setEditingPreset] = useState<RoutinePreset | null | undefined>(undefined);
  const [viewingLogsPreset, setViewingLogsPreset] = useState<RoutinePreset | null>(null);
  const [activeMenuId, setActiveMenuId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  if (editingPreset !== undefined) {
    return (
      <PresetEditor
        initialPreset={editingPreset}
        onClose={() => setEditingPreset(undefined)}
      />
    );
  }

  const handleStart = (preset: RoutinePreset) => {
    loadPreset(preset, true);
  };

  const filteredPresets = presets.filter((p) => {
    const q = searchQuery.toLowerCase();
    return p.name.toLowerCase().includes(q) || p.description.toLowerCase().includes(q);
  });

  return (
    <div className="space-y-8 pb-24">
      {/* Studio Header & Action Bar */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 pb-2 border-b border-[var(--color-border-subtle)]">
        <div>
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-xs font-bold text-[#9123A6] dark:text-[#D7195F] mb-2">
            <Sparkles size={13} className="text-[#D7195F]" />
            <span>ROUTINE LIBRARY</span>
          </div>
          <h1 className="text-3xl sm:text-4xl font-black tracking-tight">Routines & Presets</h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-1">
            Choose from curated templates or build tailored multi-step interval workflows.
          </p>
        </div>

        <div className="flex items-center gap-3">
          {/* Search Bar */}
          <div className="relative">
            <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[var(--color-text-muted)]" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search routines..."
              className="pl-10 pr-4 py-2.5 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-xs font-semibold text-[var(--color-text-main)] focus:outline-none focus:ring-2 focus:ring-[var(--color-focus)] w-48 sm:w-64 transition-all"
            />
          </div>

          <NeuButton
            variant="primary"
            size="md"
            onClick={() => setEditingPreset(null)}
            className="rounded-2xl shrink-0"
          >
            <Plus size={16} />
            <span>New Routine</span>
          </NeuButton>
        </div>
      </div>

      {/* Routine Cards Desktop Grid (3-column responsive) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredPresets.map((preset) => {
          const iterationDurationSec = preset.phases.reduce((acc, p) => acc + p.durationInSeconds, 0);
          const totalDurationSec = iterationDurationSec * preset.iterations;
          const totalMinutes = Math.floor(totalDurationSec / 60);
          const displayHours = Math.floor(totalMinutes / 60);
          const displayMinutes = totalMinutes % 60;
          const timeLabel =
            displayHours > 0
              ? `${displayHours}h ${displayMinutes > 0 ? `${displayMinutes}m` : ''}`
              : `${totalMinutes} min`;

          const isMenuOpen = activeMenuId === preset.id;

          const presetLogs = getLogsForPreset(preset.id);
          const logsCount = presetLogs.length;

          return (
            <NeuCard
              key={preset.id}
              className="relative p-6 flex flex-col justify-between transition-all hover:translate-y-[-2px] group"
            >
              <div>
                {/* Header row */}
                <div className="flex items-start justify-between gap-3 mb-3">
                  <div className="flex-1 cursor-pointer" onClick={() => handleStart(preset)}>
                    <h3 className="font-extrabold text-lg group-hover:text-[#D7195F] transition-colors leading-snug">
                      {preset.name}
                    </h3>
                  </div>

                  {/* Actions Dropdown */}
                  <div className="relative">
                    <button
                      onClick={() => setActiveMenuId(isMenuOpen ? null : preset.id)}
                      className="p-1.5 rounded-xl hover:bg-black/5 dark:hover:bg-white/5 text-[var(--color-text-muted)] transition-all"
                      title="More Options"
                    >
                      <MoreVertical size={18} />
                    </button>

                    {isMenuOpen && (
                      <>
                        <div className="fixed inset-0 z-30" onClick={() => setActiveMenuId(null)} />
                        <div className="absolute right-0 top-9 w-44 z-40 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 py-2 text-xs font-bold shadow-lg shadow-black/10">
                          <button
                            onClick={() => {
                              setActiveMenuId(null);
                              setViewingLogsPreset(preset);
                            }}
                            className="w-full px-4 py-2.5 text-left flex items-center gap-2.5 hover:bg-black/5 dark:hover:bg-white/5 text-emerald-600 dark:text-emerald-400"
                          >
                            <History size={14} />
                            <span>Show Logs {logsCount > 0 ? `(${logsCount})` : ''}</span>
                          </button>
                          <button
                            onClick={() => {
                              setActiveMenuId(null);
                              setEditingPreset(preset);
                            }}
                            className="w-full px-4 py-2.5 text-left flex items-center gap-2.5 hover:bg-black/5 dark:hover:bg-white/5"
                          >
                            <Edit2 size={14} />
                            <span>Edit Routine</span>
                          </button>
                          <button
                            onClick={() => {
                              setActiveMenuId(null);
                              duplicatePreset(preset);
                            }}
                            className="w-full px-4 py-2.5 text-left flex items-center gap-2.5 hover:bg-black/5 dark:hover:bg-white/5"
                          >
                            <Copy size={14} />
                            <span>Duplicate</span>
                          </button>
                          <button
                            onClick={() => {
                              setActiveMenuId(null);
                              if (confirm(`Delete routine "${preset.name}"?`)) {
                                deletePreset(preset.id);
                              }
                            }}
                            className="w-full px-4 py-2.5 text-left flex items-center gap-2.5 text-rose-500 hover:bg-rose-500/10"
                          >
                            <Trash2 size={14} />
                            <span>Delete</span>
                          </button>
                        </div>
                      </>
                    )}
                  </div>
                </div>

                {/* Description */}
                {preset.description && (
                  <p className="text-xs text-[var(--color-text-muted)] line-clamp-2 mb-4 leading-relaxed">
                    {preset.description}
                  </p>
                )}

                {/* Visual Phase Ratio Timeline Bar */}
                <div className="mb-4 space-y-1">
                  <div className="w-full h-2 rounded-full overflow-hidden flex bg-slate-100 dark:bg-slate-800">
                    {preset.phases.map((p, idx) => {
                      const ratio = iterationDurationSec > 0 ? (p.durationInSeconds / iterationDurationSec) * 100 : 50;
                      const color = p.color || (p.type === 'focus' ? activeFocusColor : activeBreakColor);
                      return (
                        <div
                          key={idx}
                          style={{ width: `${ratio}%`, backgroundColor: color }}
                          className="h-full first:rounded-l-full last:rounded-r-full"
                          title={`${p.name}: ${Math.floor(p.durationInSeconds / 60)}m`}
                        />
                      );
                    })}
                  </div>
                </div>

                {/* Badges Matrix (Clean & peaceful flat chips) */}
                <div className="flex flex-wrap items-center gap-2 mb-4">
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-xs font-bold bg-[#D7195F]/10 text-[#D7195F]">
                    <Clock size={12} />
                    <span>{timeLabel}</span>
                  </span>
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-[var(--color-text-muted)]">
                    <Repeat2 size={12} />
                    <span>{preset.iterations}x cycles</span>
                  </span>
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-[var(--color-text-muted)]">
                    <Layers size={12} />
                    <span>{preset.phases.length} steps</span>
                  </span>
                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      setViewingLogsPreset(preset);
                    }}
                    className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-xs font-bold transition-colors ${
                      logsCount > 0
                        ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-500/20'
                        : 'bg-slate-100 dark:bg-slate-800 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)]'
                    }`}
                    title="View completion logs"
                  >
                    <History size={12} />
                    <span>{logsCount > 0 ? `${logsCount} ${logsCount === 1 ? 'run' : 'runs'}` : '0 logs'}</span>
                  </button>
                </div>
              </div>

              {/* Card Footer: Step list, Logs Button & Launch Button */}
              <div className="pt-4 border-t border-[var(--color-border-subtle)] flex items-center justify-between gap-2.5 mt-auto">
                <div className="text-[11px] text-[var(--color-text-muted)] font-medium truncate flex-1">
                  {preset.phases.map((p) => p.name).join(' → ')}
                </div>

                <div className="flex items-center gap-2 shrink-0">
                  <button
                    type="button"
                    onClick={() => setViewingLogsPreset(preset)}
                    className="px-3 py-1.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 border border-slate-200/60 dark:border-slate-700 flex items-center gap-1.5 text-xs font-bold text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors active:scale-95"
                    title="Show Routine Logs"
                  >
                    <History size={13} className={logsCount > 0 ? 'text-emerald-500' : ''} />
                    <span>Logs</span>
                    {logsCount > 0 && (
                      <span className="px-1.5 py-0.2 rounded-full bg-emerald-500/20 text-emerald-600 dark:text-emerald-400 text-[10px] font-black">
                        {logsCount}
                      </span>
                    )}
                  </button>

                  <NeuButton
                    variant="primary"
                    size="sm"
                    onClick={() => handleStart(preset)}
                    className="rounded-xl px-4 py-2 group/btn"
                  >
                    <Play size={13} fill="currentColor" className="group-hover/btn:scale-110 transition-transform" />
                    <span>Start</span>
                  </NeuButton>
                </div>
              </div>
            </NeuCard>
          );
        })}
      </div>

      {filteredPresets.length === 0 && (
        <div className="text-center py-16 rounded-3xl bg-slate-50 dark:bg-slate-900/40 border border-dashed border-slate-200 dark:border-slate-800">
          <p className="text-sm font-bold text-[var(--color-text-muted)]">
            No routines found matching "{searchQuery}"
          </p>
        </div>
      )}

      {/* Routine Completion Logs Modal */}
      {viewingLogsPreset && (
        <RoutineLogsModal
          preset={viewingLogsPreset}
          onClose={() => setViewingLogsPreset(null)}
        />
      )}
    </div>
  );
};

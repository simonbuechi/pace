import React from 'react';
import {
  X,
  History,
  Calendar,
  Clock,
  Repeat2,
  Trash2,
  CheckCircle2,
  Flame,
  Coffee,
  Sparkles,
} from 'lucide-react';
import type { RoutinePreset } from '../../types';
import { usePresets } from '../../context/PresetsContext';
import { useSettings } from '../../context/SettingsContext';
import { NeuButton } from '../common/NeuButton';

interface RoutineLogsModalProps {
  preset: RoutinePreset;
  onClose: () => void;
}

export const RoutineLogsModal: React.FC<RoutineLogsModalProps> = ({ preset, onClose }) => {
  const { getLogsForPreset, deleteRoutineLog, clearLogsForPreset } = usePresets();
  const { activeFocusColor, activeBreakColor } = useSettings();

  const presetLogs = getLogsForPreset(preset.id);

  const formatDuration = (secs: number) => {
    const hrs = Math.floor(secs / 3600);
    const mins = Math.floor((secs % 3600) / 60);
    const s = secs % 60;
    if (hrs > 0) return `${hrs}h ${mins}m`;
    if (mins > 0) return `${mins}m ${s > 0 ? `${s}s` : ''}`.trim();
    return `${s}s`;
  };

  const formatDate = (isoString: string) => {
    const d = new Date(isoString);
    const today = new Date();
    const isToday = d.toDateString() === today.toDateString();

    const timeStr = d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    if (isToday) return `Today at ${timeStr}`;

    return `${d.toLocaleDateString([], { month: 'short', day: 'numeric', year: 'numeric' })} at ${timeStr}`;
  };

  const totalTimeSeconds = presetLogs.reduce((acc, l) => acc + l.totalDurationInSeconds, 0);
  const totalFocusSeconds = presetLogs.reduce((acc, l) => acc + l.focusDurationInSeconds, 0);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-fadeIn">
      {/* Modal Dialog Card */}
      <div className="w-full max-w-2xl rounded-3xl neu-raised bg-[var(--color-surface-card)] border border-white/20 dark:border-white/5 overflow-hidden shadow-xl shadow-black/15 flex flex-col max-h-[85vh]">
        {/* Header */}
        <div className="p-6 pb-4 border-b border-[var(--color-border-subtle)] flex items-start justify-between gap-4">
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-0.5 rounded-full bg-slate-100 dark:bg-slate-800 text-[11px] font-bold text-[#9123A6] dark:text-[#D7195F] mb-1.5">
              <Sparkles size={12} className="text-[#D7195F]" />
              <span>COMPLETION LOGS</span>
            </div>
            <h2 className="text-2xl font-extrabold tracking-tight text-[var(--color-text-main)]">
              {preset.name}
            </h2>
            <p className="text-xs text-[var(--color-text-muted)] mt-0.5">
              History of all sessions that completed successfully without cancellation.
            </p>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] transition-colors shrink-0"
            title="Close"
          >
            <X size={18} />
          </button>
        </div>

        {/* Aggregate Telemetry Strip */}
        {presetLogs.length > 0 && (
          <div className="px-6 py-4 bg-black/5 dark:bg-white/5 border-b border-[var(--color-border-subtle)] grid grid-cols-3 gap-3">
            <div className="text-center">
              <span className="text-[10px] font-bold uppercase tracking-wider text-[var(--color-text-muted)] block">
                Total Runs
              </span>
              <span className="text-lg font-black font-mono-numbers text-[var(--color-text-main)]">
                {presetLogs.length} {presetLogs.length === 1 ? 'session' : 'sessions'}
              </span>
            </div>

            <div className="text-center border-x border-[var(--color-border-subtle)]">
              <span className="text-[10px] font-bold uppercase tracking-wider text-[var(--color-text-muted)] block">
                Total Completed
              </span>
              <span className="text-lg font-black font-mono-numbers text-[#D7195F]">
                {formatDuration(totalTimeSeconds)}
              </span>
            </div>

            <div className="text-center">
              <span className="text-[10px] font-bold uppercase tracking-wider text-[var(--color-text-muted)] block">
                Focus Time
              </span>
              <span className="text-lg font-black font-mono-numbers text-emerald-600 dark:text-emerald-400">
                {formatDuration(totalFocusSeconds)}
              </span>
            </div>
          </div>
        )}

        {/* Logs List Area */}
        <div className="p-6 overflow-y-auto space-y-3 flex-1">
          {presetLogs.length === 0 ? (
            <div className="text-center py-12 px-4 space-y-3">
              <div className="w-14 h-14 mx-auto rounded-2xl bg-slate-100 dark:bg-slate-800/80 border border-slate-200/60 dark:border-slate-700/60 flex items-center justify-center text-[var(--color-text-muted)]">
                <History size={26} />
              </div>
              <div>
                <h3 className="font-extrabold text-base text-[var(--color-text-main)]">
                  No Completion Logs Yet
                </h3>
                <p className="text-xs text-[var(--color-text-muted)] max-w-sm mx-auto mt-1 leading-relaxed">
                  When you run "{preset.name}" and finish all cycles without cancelling, its full session duration and timestamp will be logged here.
                </p>
              </div>
            </div>
          ) : (
            presetLogs.map((log) => (
              <div
                key={log.id}
                className="p-4 rounded-2xl bg-slate-50 dark:bg-slate-800/50 border border-slate-200/60 dark:border-slate-700/60 flex flex-col sm:flex-row sm:items-center justify-between gap-3 transition-colors"
              >
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 flex items-center justify-center shrink-0 mt-0.5">
                    <CheckCircle2 size={18} />
                  </div>

                  <div className="space-y-1">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="font-bold text-sm text-[var(--color-text-main)] flex items-center gap-1.5">
                        <Calendar size={13} className="text-[var(--color-text-muted)]" />
                        {formatDate(log.completedAt)}
                      </span>
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
                        COMPLETED
                      </span>
                    </div>

                    <div className="flex items-center gap-3 text-xs text-[var(--color-text-muted)] flex-wrap">
                      <span className="flex items-center gap-1 font-semibold text-[var(--color-text-main)]">
                        <Clock size={12} />
                        {formatDuration(log.totalDurationInSeconds)}
                      </span>
                      <span>•</span>
                      <span className="flex items-center gap-1">
                        <Repeat2 size={12} />
                        {log.cyclesCompleted} {log.cyclesCompleted === 1 ? 'cycle' : 'cycles'}
                      </span>
                      <span>•</span>
                      <span className="flex items-center gap-1" style={{ color: activeFocusColor }}>
                        <Flame size={12} />
                        {formatDuration(log.focusDurationInSeconds)} focus
                      </span>
                      <span>•</span>
                      <span className="flex items-center gap-1" style={{ color: activeBreakColor }}>
                        <Coffee size={12} />
                        {formatDuration(log.breakDurationInSeconds)} break
                      </span>
                    </div>
                  </div>
                </div>

                <div className="self-end sm:self-center">
                  <button
                    onClick={() => deleteRoutineLog(log.id)}
                    className="p-2 rounded-xl text-rose-500/70 hover:text-rose-500 hover:bg-rose-500/10 transition-colors"
                    title="Delete this log entry"
                  >
                    <Trash2 size={15} />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Modal Footer */}
        <div className="p-4 px-6 border-t border-[var(--color-border-subtle)] flex items-center justify-between gap-3">
          {presetLogs.length > 0 ? (
            <button
              onClick={() => {
                if (confirm(`Clear all ${presetLogs.length} logs for "${preset.name}"?`)) {
                  clearLogsForPreset(preset.id);
                }
              }}
              className="text-xs font-bold text-rose-500 hover:underline flex items-center gap-1.5"
            >
              <Trash2 size={13} />
              <span>Clear Routine History</span>
            </button>
          ) : (
            <div />
          )}

          <NeuButton size="sm" variant="subtle" onClick={onClose} className="px-5">
            Close
          </NeuButton>
        </div>
      </div>
    </div>
  );
};

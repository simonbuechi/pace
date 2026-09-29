import React, { useEffect, useState } from 'react';
import {
  Palette,
  Volume2,
  Bell,
  Cloud,
  Sun,
  Moon,
  Monitor,
  Play,
  Check,
  Sparkles,
  LogOut,
  ShieldCheck,
  RotateCcw,
  Sliders,
  CheckCircle2,
  HardDrive,
  Keyboard,
} from 'lucide-react';
import { useSettings } from '../../context/SettingsContext';
import { CURATED_PALETTES } from '../../core/palettes';
import { APP_SOUNDS } from '../../core/audio';
import { syncController, type UserProfile } from '../../core/sync';
import { usePresets } from '../../context/PresetsContext';
import { NeuCard } from '../common/NeuCard';
import { NeuButton } from '../common/NeuButton';
import { NeuSlider } from '../common/NeuSlider';
import type { SoundId, ThemeMode } from '../../types';

export const Settings: React.FC = () => {
  const {
    settings,
    currentPalette,
    activeFocusColor,
    activeBreakColor,
    updateThemeMode,
    updatePalette,
    updateCustomColors,
    updateFocusSound,
    updateBreakSound,
    toggleSound,
    updateVolume,
    toggleNotifications,
    previewSound,
  } = useSettings();

  const { presets } = usePresets();
  const [syncUser, setSyncUser] = useState<UserProfile | null>(syncController.getUser());

  useEffect(() => {
    return syncController.subscribe((_state, user) => {
      setSyncUser(user);
    });
  }, []);

  const hasCustomColors = Boolean(settings.customFocusColor || settings.customBreakColor);

  return (
    <div className="space-y-8 pb-24">
      {/* Studio Header & Quick Status Strip */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 pb-4 border-b border-[var(--color-border-subtle)]">
        <div>
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-xs font-bold text-[#9123A6] dark:text-[#D7195F] mb-2">
            <Sparkles size={13} className="text-[#D7195F]" />
            <span>STUDIO CONFIGURATION</span>
          </div>
          <h1 className="text-3xl sm:text-4xl font-black tracking-tight">Settings & Preferences</h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-1">
            Personalize tactile color themes, synthesized audio alerts, and cross-device cloud synchronization.
          </p>
        </div>

        {/* Quick status summary chips */}
        <div className="flex flex-wrap items-center gap-2">
          <div className="px-3 py-1.5 rounded-xl bg-slate-100 dark:bg-slate-800/80 border border-slate-200/60 dark:border-slate-700/60 flex items-center gap-2 text-xs font-bold text-[var(--color-text-muted)]">
            <div
              className="w-2.5 h-2.5 rounded-full"
              style={{ backgroundColor: activeFocusColor }}
            />
            <span>{hasCustomColors ? 'Custom Colors' : currentPalette.name}</span>
          </div>
          <div className="px-3 py-1.5 rounded-xl bg-slate-100 dark:bg-slate-800/80 border border-slate-200/60 dark:border-slate-700/60 flex items-center gap-1.5 text-xs font-bold text-[var(--color-text-muted)]">
            <Volume2 size={13} className={settings.soundEnabled ? 'text-emerald-500' : 'text-slate-400'} />
            <span>{settings.soundEnabled ? `${Math.round(settings.soundVolume * 100)}% Vol` : 'Muted'}</span>
          </div>
          <div className="px-3 py-1.5 rounded-xl bg-slate-100 dark:bg-slate-800/80 border border-slate-200/60 dark:border-slate-700/60 flex items-center gap-1.5 text-xs font-bold text-[var(--color-text-muted)]">
            <Cloud size={13} className={syncUser ? 'text-emerald-500' : 'text-amber-500'} />
            <span>{syncUser ? 'Synced' : 'Local Only'}</span>
          </div>
        </div>
      </div>

      {/* 1. Full-Width Cloud Sync & Storage Hub */}
      <NeuCard className="p-6">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-center">
          <div className="lg:col-span-8 flex flex-col sm:flex-row items-start sm:items-center gap-4">
            <div
              className={`w-12 h-12 rounded-2xl flex items-center justify-center text-white shrink-0 ${
                syncUser ? 'bg-emerald-500' : 'bg-gradient-to-br from-[#9123A6] to-[#D7195F]'
              }`}
            >
              <Cloud size={24} />
            </div>

            <div className="space-y-1">
              <div className="flex items-center gap-2.5 flex-wrap">
                <h3 className="font-extrabold text-lg text-[var(--color-text-main)]">
                  {syncUser ? `Connected as ${syncUser.displayName || syncUser.email}` : 'Local Storage Mode'}
                </h3>
                <span
                  className={`px-2.5 py-0.5 rounded-full text-[11px] font-bold tracking-wide ${
                    syncUser ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' : 'bg-amber-500/10 text-amber-600 dark:text-amber-400'
                  }`}
                >
                  {syncUser ? 'CLOUD SYNC ACTIVE' : 'OFFLINE FIRST'}
                </span>
              </div>
              <p className="text-xs text-[var(--color-text-muted)] leading-relaxed max-w-2xl">
                {syncUser
                  ? `Your presets and audio configurations are automatically mirrored to your secure cloud profile (${syncUser.email}).`
                  : 'Pace Amigo saves all routines locally in your browser storage. Sign in with Google to synchronize routines across desktop, laptop, and mobile browsers.'}
              </p>
            </div>
          </div>

          <div className="lg:col-span-4 flex flex-col sm:flex-row lg:flex-col justify-end gap-3 w-full">
            {syncUser ? (
              <NeuButton
                size="sm"
                variant="subtle"
                onClick={() => syncController.signOut()}
                className="w-full py-2.5 rounded-2xl flex items-center justify-center gap-2 text-rose-500 hover:text-rose-600 font-bold"
              >
                <LogOut size={16} />
                <span>Disconnect Google Account</span>
              </NeuButton>
            ) : (
              <NeuButton
                variant="primary"
                size="md"
                onClick={() => syncController.signInWithGoogle()}
                className="w-full py-3 rounded-2xl flex items-center justify-center gap-2.5 font-bold shadow-md"
              >
                <ShieldCheck size={18} />
                <span>Sign in with Google</span>
              </NeuButton>
            )}

            <div className="flex items-center justify-center gap-4 text-[11px] font-semibold text-[var(--color-text-muted)]">
              <span className="flex items-center gap-1">
                <HardDrive size={12} />
                {presets.length} Routines Stored
              </span>
              <span>•</span>
              <span className="flex items-center gap-1 text-emerald-600 dark:text-emerald-400">
                <CheckCircle2 size={12} />
                Zero Latency
              </span>
            </div>
          </div>
        </div>
      </NeuCard>

      {/* 2. Main 2-Column Desktop Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Left Column: Aesthetics & Palettes (6 cols) */}
        <div className="lg:col-span-6 space-y-6">
          {/* Appearance Mode */}
          <NeuCard className="p-6 space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-[var(--color-border-subtle)]">
              <div className="flex items-center gap-2">
                <Sun size={18} className="text-[var(--color-focus)]" />
                <h2 className="font-extrabold text-base">Interface Appearance</h2>
              </div>
              <span className="text-xs font-bold text-[var(--color-text-muted)] uppercase tracking-wider">
                {settings.themeMode}
              </span>
            </div>

            <div className="grid grid-cols-3 gap-3">
              {(
                [
                  { mode: 'light', label: 'Light', desc: 'Crisp & Soft', icon: Sun },
                  { mode: 'dark', label: 'Dark', desc: 'Midnight Glow', icon: Moon },
                  { mode: 'system', label: 'System', desc: 'OS Adaptive', icon: Monitor },
                ] as const
              ).map(({ mode, label, desc, icon: Icon }) => {
                const isSelected = settings.themeMode === mode;
                return (
                  <button
                    key={mode}
                    type="button"
                    onClick={() => updateThemeMode(mode as ThemeMode)}
                    className={`p-3.5 rounded-2xl flex flex-col items-center gap-2 text-center transition-all border ${
                      isSelected
                        ? 'bg-[var(--color-focus)]/10 text-[var(--color-focus)] border-2 border-[var(--color-focus)] shadow-sm'
                        : 'bg-slate-50 dark:bg-slate-800/40 border-slate-200/60 dark:border-slate-800 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] hover:border-slate-300 dark:hover:border-slate-700'
                    }`}
                  >
                    <Icon size={20} className={isSelected ? 'text-[var(--color-focus)]' : ''} />
                    <div>
                      <div className="font-bold text-xs">{label}</div>
                      <div className="text-[10px] text-[var(--color-text-muted)]">{desc}</div>
                    </div>
                  </button>
                );
              })}
            </div>
          </NeuCard>

          {/* Curated Color Palettes */}
          <NeuCard className="p-6 space-y-5">
            <div className="flex items-center justify-between pb-2 border-b border-[var(--color-border-subtle)]">
              <div className="flex items-center gap-2">
                <Palette size={18} className="text-[var(--color-focus)]" />
                <h2 className="font-extrabold text-base">Curated Palettes</h2>
              </div>
              <span className="text-xs font-bold text-[var(--color-text-muted)]">
                Material 3 Expressive
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
              {CURATED_PALETTES.map((pal) => {
                const isSelected =
                  pal.id === currentPalette.id &&
                  !settings.customFocusColor &&
                  !settings.customBreakColor;

                return (
                  <div
                    key={pal.id}
                    onClick={() => updatePalette(pal.id)}
                    className={`p-4 rounded-2xl cursor-pointer transition-all border ${
                      isSelected
                        ? 'bg-[var(--color-focus)]/5 border-2 border-[var(--color-focus)] shadow-sm'
                        : 'bg-slate-50/60 dark:bg-slate-800/40 border-slate-200/60 dark:border-slate-800 hover:border-slate-300 dark:hover:border-slate-700'
                    }`}
                  >
                    <div className="flex items-center justify-between mb-3">
                      <span className="font-extrabold text-sm">{pal.name}</span>
                      {isSelected && (
                        <div
                          className="w-5 h-5 rounded-full text-white flex items-center justify-center text-xs shadow-sm"
                          style={{ backgroundColor: activeFocusColor }}
                        >
                          <Check size={12} strokeWidth={3} />
                        </div>
                      )}
                    </div>

                    {/* Dual Color Swatch Display */}
                    <div className="flex items-center gap-2 mb-2.5">
                      <div
                        className="w-8 h-8 rounded-xl border border-black/10 dark:border-white/10 shadow-sm flex items-center justify-center"
                        style={{ backgroundColor: pal.focusColor }}
                        title="Focus Interval Background"
                      />
                      <div
                        className="w-8 h-8 rounded-xl border border-black/10 dark:border-white/10 shadow-sm flex items-center justify-center"
                        style={{ backgroundColor: pal.breakColor }}
                        title="Break Interval Background"
                      />
                      <div className="ml-1 text-[10px] font-bold text-[var(--color-text-muted)] uppercase tracking-wider">
                        Focus / Rest
                      </div>
                    </div>

                    <p className="text-[11px] text-[var(--color-text-muted)] line-clamp-1">
                      {pal.description}
                    </p>
                  </div>
                );
              })}
            </div>

            {/* Custom Color Overrides */}
            <div className="pt-3 border-t border-[var(--color-border-subtle)] space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)] flex items-center gap-1.5">
                  <Sliders size={13} />
                  <span>Custom Color Overrides</span>
                </span>
                {hasCustomColors && (
                  <button
                    type="button"
                    onClick={() => updateCustomColors(undefined, undefined)}
                    className="flex items-center gap-1 text-[11px] font-bold text-[var(--color-focus)] hover:underline"
                  >
                    <RotateCcw size={12} />
                    <span>Reset to Defaults</span>
                  </button>
                )}
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-[var(--color-text-muted)] block">
                    Focus Interval
                  </label>
                  <div className="flex items-center gap-2.5 px-3 py-2 rounded-2xl bg-slate-100 dark:bg-slate-800/70 border border-slate-200/70 dark:border-slate-700/70">
                    <input
                      type="color"
                      value={activeFocusColor}
                      onChange={(e) => updateCustomColors(e.target.value, undefined)}
                      className="w-7 h-7 rounded-xl cursor-pointer border-none bg-transparent"
                    />
                    <span className="text-xs font-mono-numbers font-black uppercase text-[var(--color-text-main)]">
                      {activeFocusColor}
                    </span>
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-[var(--color-text-muted)] block">
                    Break Interval
                  </label>
                  <div className="flex items-center gap-2.5 px-3 py-2 rounded-2xl bg-slate-100 dark:bg-slate-800/70 border border-slate-200/70 dark:border-slate-700/70">
                    <input
                      type="color"
                      value={activeBreakColor}
                      onChange={(e) => updateCustomColors(undefined, e.target.value)}
                      className="w-7 h-7 rounded-xl cursor-pointer border-none bg-transparent"
                    />
                    <span className="text-xs font-mono-numbers font-black uppercase text-[var(--color-text-main)]">
                      {activeBreakColor}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </NeuCard>
        </div>

        {/* Right Column: Audio & Notifications Soundboard (6 cols) */}
        <div className="lg:col-span-6 space-y-6">
          {/* Audio Master Card */}
          <NeuCard className="p-6 space-y-6">
            <div className="flex items-center justify-between pb-2 border-b border-[var(--color-border-subtle)]">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[var(--color-focus)]/10 text-[var(--color-focus)] flex items-center justify-center">
                  <Volume2 size={20} />
                </div>
                <div>
                  <h2 className="font-extrabold text-base">Web Audio Synthesizer</h2>
                  <p className="text-xs text-[var(--color-text-muted)]">
                    Pure real-time procedural alerts with zero external audio assets
                  </p>
                </div>
              </div>

              {/* Master Audio Toggle */}
              <button
                type="button"
                onClick={() => toggleSound(!settings.soundEnabled)}
                className={`w-14 h-8 rounded-full transition-all p-1 flex items-center ${
                  settings.soundEnabled
                    ? 'bg-gradient-to-r from-[#9123A6] to-[#D7195F]'
                    : 'bg-slate-200 dark:bg-slate-700'
                }`}
                title="Toggle Master Audio"
              >
                <div
                  className={`w-6 h-6 rounded-full bg-white shadow-md transform transition-transform ${
                    settings.soundEnabled ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>

            {/* Volume Control */}
            {settings.soundEnabled && (
              <div className="space-y-2 p-4 rounded-2xl bg-slate-50 dark:bg-slate-800/40 border border-slate-200/60 dark:border-slate-800">
                <div className="flex justify-between items-center text-xs font-bold">
                  <span className="text-[var(--color-text-muted)]">Master Alert Volume</span>
                  <span className="font-mono-numbers font-black text-sm text-[var(--color-focus)]">
                    {Math.round(settings.soundVolume * 100)}%
                  </span>
                </div>
                <NeuSlider
                  min={0}
                  max={1}
                  step={0.05}
                  value={settings.soundVolume}
                  onChange={(v) => updateVolume(v)}
                  accentColor="var(--color-focus)"
                />
              </div>
            )}

            {/* Soundboard Grids */}
            <div className="space-y-5">
              {/* Focus Interval Sound Selection */}
              <div className="space-y-2.5">
                <div className="flex items-center justify-between">
                  <label className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)]">
                    Focus Interval Alert
                  </label>
                  <span className="text-[11px] font-semibold text-[var(--color-focus)]">
                    Plays when focus begins
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5">
                  {APP_SOUNDS.map((s) => {
                    const isSelected = settings.focusSoundId === s.id;
                    return (
                      <div
                        key={`focus_${s.id}`}
                        onClick={() => updateFocusSound(s.id as SoundId)}
                        className={`p-3 rounded-2xl cursor-pointer transition-all flex flex-col justify-between border ${
                          isSelected
                            ? 'bg-[var(--color-focus)]/5 border-2 border-[var(--color-focus)] shadow-sm'
                            : 'bg-slate-50/60 dark:bg-slate-800/40 border-slate-200/60 dark:border-slate-800 hover:border-slate-300 dark:hover:border-slate-700'
                        }`}
                      >
                        <div className="mb-2">
                          <div className="font-bold text-xs text-[var(--color-text-main)] flex items-center justify-between">
                            <span>{s.name}</span>
                            {isSelected && <Check size={12} className="text-[var(--color-focus)]" />}
                          </div>
                          <div className="text-[10px] text-[var(--color-text-muted)] line-clamp-1 mt-0.5">
                            {s.description}
                          </div>
                        </div>

                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            previewSound(s.id as SoundId);
                          }}
                          className="w-full py-1.5 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 hover:border-slate-300 dark:hover:border-slate-600 flex items-center justify-center gap-1.5 text-[11px] font-bold text-[var(--color-focus)] active:scale-95 transition-all"
                        >
                          <Play size={12} fill="currentColor" />
                          <span>Test</span>
                        </button>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Break Interval Sound Selection */}
              <div className="space-y-2.5 pt-2 border-t border-[var(--color-border-subtle)]">
                <div className="flex items-center justify-between">
                  <label className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-muted)]">
                    Break Interval Alert
                  </label>
                  <span className="text-[11px] font-semibold text-[var(--color-break)]">
                    Plays when rest begins
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5">
                  {APP_SOUNDS.map((s) => {
                    const isSelected = settings.breakSoundId === s.id;
                    return (
                      <div
                        key={`break_${s.id}`}
                        onClick={() => updateBreakSound(s.id as SoundId)}
                        className={`p-3 rounded-2xl cursor-pointer transition-all flex flex-col justify-between border ${
                          isSelected
                            ? 'bg-[var(--color-break)]/5 border-2 border-[var(--color-break)] shadow-sm'
                            : 'bg-slate-50/60 dark:bg-slate-800/40 border-slate-200/60 dark:border-slate-800 hover:border-slate-300 dark:hover:border-slate-700'
                        }`}
                      >
                        <div className="mb-2">
                          <div className="font-bold text-xs text-[var(--color-text-main)] flex items-center justify-between">
                            <span>{s.name}</span>
                            {isSelected && <Check size={12} className="text-[var(--color-break)]" />}
                          </div>
                          <div className="text-[10px] text-[var(--color-text-muted)] line-clamp-1 mt-0.5">
                            {s.description}
                          </div>
                        </div>

                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            previewSound(s.id as SoundId);
                          }}
                          className="w-full py-1.5 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 hover:border-slate-300 dark:hover:border-slate-600 flex items-center justify-center gap-1.5 text-[11px] font-bold text-[var(--color-break)] active:scale-95 transition-all"
                        >
                          <Play size={12} fill="currentColor" />
                          <span>Test</span>
                        </button>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          </NeuCard>

          {/* Desktop Notifications & Integration Card */}
          <NeuCard className="p-6 space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-[var(--color-border-subtle)]">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-indigo-500/10 text-indigo-500 flex items-center justify-center">
                  <Bell size={20} />
                </div>
                <div>
                  <h3 className="font-extrabold text-base">Desktop Notifications</h3>
                  <p className="text-xs text-[var(--color-text-muted)]">
                    Receive interval alerts when Pace is running in background browser tabs
                  </p>
                </div>
              </div>

              <button
                type="button"
                onClick={() => toggleNotifications(!settings.notificationsEnabled)}
                className={`w-14 h-8 rounded-full transition-all p-1 flex items-center ${
                  settings.notificationsEnabled
                    ? 'bg-indigo-500'
                    : 'bg-slate-200 dark:bg-slate-700'
                }`}
                title="Toggle Desktop Notifications"
              >
                <div
                  className={`w-6 h-6 rounded-full bg-white shadow-md transform transition-transform ${
                    settings.notificationsEnabled ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>

            <div className="flex items-center justify-between text-xs text-[var(--color-text-muted)] pt-1">
              <span className="flex items-center gap-1.5">
                <Keyboard size={14} />
                <span>Web App Shortcuts: <code className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 font-bold">1</code> Quick, <code className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 font-bold">2</code> Routines, <code className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 font-bold">3</code> Settings</span>
              </span>
            </div>
          </NeuCard>
        </div>
      </div>
    </div>
  );
};


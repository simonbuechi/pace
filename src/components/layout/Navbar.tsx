import React, { useState } from 'react';
import {
  Zap,
  Layers,
  Settings as SettingsIcon,
  Sun,
  Moon,
  Maximize2,
  Minimize2,
  Keyboard,
  X,
  Play,
  Pause,
} from 'lucide-react';
import { useSettings } from '../../context/SettingsContext';
import { useTimer } from '../../context/TimerContext';

export type NavTab = 'quick' | 'routines' | 'settings';

interface NavbarProps {
  activeTab: NavTab;
  onTabChange: (tab: NavTab) => void;
}

export const Navbar: React.FC<NavbarProps> = ({ activeTab, onTabChange }) => {
  const { settings, updateThemeMode } = useSettings();
  const { state, currentPhase, formattedTime, openVisualizer, pause, resume, toggleFullscreen } =
    useTimer();
  const [showShortcuts, setShowShortcuts] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);

  const isDark =
    settings.themeMode === 'dark' ||
    (settings.themeMode === 'system' &&
      typeof window !== 'undefined' &&
      window.matchMedia('(prefers-color-scheme: dark)').matches);

  const toggleTheme = () => {
    updateThemeMode(isDark ? 'light' : 'dark');
  };

  const handleFullscreenClick = () => {
    toggleFullscreen();
    setIsFullscreen(!isFullscreen);
  };

  const navItems: { id: NavTab; label: string; shortcut: string; icon: React.ElementType }[] = [
    { id: 'quick', label: 'Quick Start', shortcut: '1', icon: Zap },
    { id: 'routines', label: 'Routines & Presets', shortcut: '2', icon: Layers },
    { id: 'settings', label: 'Studio Settings', shortcut: '3', icon: SettingsIcon },
  ];

  const isTimerActive = (state.isRunning || state.isPaused) && !state.isCompleted;

  return (
    <>
      <header className="sticky top-0 z-40 backdrop-blur-2xl bg-[var(--color-surface-base)]/85 border-b border-[var(--color-border-subtle)] transition-all">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between gap-4">
          {/* Logo & Brand Identity */}
          <div
            onClick={() => onTabChange('quick')}
            className="flex items-center gap-3.5 cursor-pointer select-none group shrink-0"
          >
            <img
              src="/logo.jpg"
              alt="Pace Amigo"
              className="w-11 h-11 rounded-2xl object-cover group-hover:scale-105 transition-transform border border-slate-200/60 dark:border-slate-700/60 shrink-0"
            />

            <div>
              <span className="font-extrabold text-xl tracking-tight leading-none">
                Pace <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#9123A6] to-[#D7195F]">Amigo</span>
              </span>
            </div>
          </div>

          {/* Desktop Navigation Tabs (Calm Segmented Control) */}
          <nav className="flex items-center gap-1 p-1 rounded-2xl bg-slate-100 dark:bg-slate-800/80 border border-slate-200/60 dark:border-slate-700/60">
            {navItems.map(({ id, label, shortcut, icon: Icon }) => {
              const isActive = activeTab === id;
              return (
                <button
                  key={id}
                  onClick={() => onTabChange(id)}
                  className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-bold transition-all relative ${
                    isActive
                      ? 'bg-white dark:bg-slate-700 text-[#D7195F] dark:text-[#FB7185] shadow-sm'
                      : 'text-[var(--color-text-muted)] hover:text-[var(--color-text-main)]'
                  }`}
                >
                  <Icon size={15} />
                  <span>{label}</span>
                  <kbd className="hidden lg:inline-block px-1.5 py-0.5 rounded text-[10px] font-bold opacity-50 bg-black/5 dark:bg-white/10">
                    {shortcut}
                  </kbd>
                </button>
              );
            })}
          </nav>

          {/* Right Action Bar */}
          <div className="flex items-center gap-2 shrink-0">
            {/* Live Header Timer Widget */}
            {isTimerActive && (
              <div
                onClick={openVisualizer}
                className="hidden md:flex items-center gap-3 px-3.5 py-1.5 rounded-2xl bg-slate-100 dark:bg-slate-800/80 border border-slate-200/60 dark:border-slate-700/60 cursor-pointer transition-all hover:border-[var(--color-focus)]/40 group"
              >
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    if (state.isRunning) pause();
                    else resume();
                  }}
                  className="w-7 h-7 rounded-xl bg-gradient-to-r from-[#9123A6] to-[#D7195F] text-white flex items-center justify-center shadow-sm"
                  title={state.isRunning ? 'Pause' : 'Resume'}
                >
                  {state.isRunning ? <Pause size={13} fill="currentColor" /> : <Play size={13} fill="currentColor" className="ml-0.5" />}
                </button>
                <div className="text-left">
                  <div className="text-[10px] font-extrabold uppercase tracking-wider text-[var(--color-text-muted)] leading-none">
                    {currentPhase.name}
                  </div>
                  <div className="text-sm font-black font-mono-numbers tracking-tight leading-tight mt-0.5 text-[var(--color-text-main)] group-hover:text-[#D7195F]">
                    {formattedTime}
                  </div>
                </div>
              </div>
            )}

            {/* Keyboard Shortcuts Trigger */}
            <button
              onClick={() => setShowShortcuts(true)}
              className="p-2.5 rounded-xl text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              title="Keyboard Shortcuts"
            >
              <Keyboard size={18} />
            </button>

            {/* Theme Toggle */}
            <button
              onClick={toggleTheme}
              className="p-2.5 rounded-xl text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              title={isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
            >
              {isDark ? <Sun size={18} /> : <Moon size={18} />}
            </button>

            {/* Fullscreen Toggle */}
            <button
              onClick={handleFullscreenClick}
              className="p-2.5 rounded-xl text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors hidden sm:block"
              title="Toggle Fullscreen"
            >
              {isFullscreen ? <Minimize2 size={18} /> : <Maximize2 size={18} />}
            </button>
          </div>
        </div>
      </header>

      {/* Keyboard Shortcuts Modal */}
      {showShortcuts && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="w-full max-w-md p-6 rounded-3xl neu-raised bg-[var(--color-surface-card)] border border-[var(--color-border-subtle)] space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-[var(--color-border-subtle)]">
              <div className="flex items-center gap-2">
                <Keyboard size={18} className="text-[#D7195F]" />
                <h3 className="font-extrabold text-base">Desktop Shortcuts</h3>
              </div>
              <button
                onClick={() => setShowShortcuts(false)}
                className="p-1 rounded-lg hover:bg-black/5 dark:hover:bg-white/5 text-[var(--color-text-muted)]"
              >
                <X size={18} />
              </button>
            </div>

            <div className="space-y-2 text-xs">
              {[
                { key: 'Space', desc: 'Play / Pause Timer' },
                { key: 'N or →', desc: 'Skip to Next Interval' },
                { key: 'P or ←', desc: 'Skip to Previous Interval' },
                { key: 'R', desc: 'Reset Active Routine' },
                { key: 'F', desc: 'Toggle Fullscreen Mode' },
                { key: 'M', desc: 'Mute / Unmute Sound Alerts' },
                { key: 'Esc', desc: 'Minimize Visualizer' },
                { key: '1, 2, 3', desc: 'Switch Navigation Tabs' },
              ].map(({ key, desc }) => (
                <div key={key} className="flex items-center justify-between py-1.5 px-3 rounded-xl bg-slate-50 dark:bg-slate-800/50 border border-slate-200/60 dark:border-slate-700/60">
                  <span className="text-[var(--color-text-muted)] font-medium">{desc}</span>
                  <kbd className="px-2 py-1 rounded bg-[var(--color-surface-card)] font-bold text-xs text-[var(--color-text-main)] border border-[var(--color-border-subtle)] shadow-sm">
                    {key}
                  </kbd>
                </div>
              ))}
            </div>

            <div className="pt-2">
              <button
                onClick={() => setShowShortcuts(false)}
                className="w-full py-2.5 rounded-xl font-bold text-xs bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-[var(--color-text-main)] transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

import React, { useEffect, useState } from 'react';
import { SettingsProvider } from './context/SettingsContext';
import { PresetsProvider } from './context/PresetsContext';
import { TimerProvider, useTimer } from './context/TimerContext';
import { Navbar, type NavTab } from './components/layout/Navbar';
import { MiniPlayer } from './components/layout/MiniPlayer';
import { QuickStart } from './components/timer/QuickStart';
import { PresetList } from './components/presets/PresetList';
import { Settings } from './components/settings/Settings';
import { TimerVisualizer } from './components/timer/TimerVisualizer';

const MainShell: React.FC = () => {
  const [activeTab, setActiveTab] = useState<NavTab>('quick');
  const { isVisualizerOpen } = useTimer();

  // Keyboard shortcut listener for tab switching (1, 2, 3)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (['INPUT', 'TEXTAREA'].includes((e.target as HTMLElement).tagName)) return;
      if (isVisualizerOpen) return;

      if (e.key === '1') setActiveTab('quick');
      else if (e.key === '2') setActiveTab('routines');
      else if (e.key === '3') setActiveTab('settings');
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isVisualizerOpen]);

  return (
    <div className="min-h-screen flex flex-col bg-[var(--color-surface-base)] text-[var(--color-text-main)] transition-colors duration-300">
      {/* Top Navbar */}
      <Navbar activeTab={activeTab} onTabChange={setActiveTab} />

      {/* Main Studio Viewport */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-10">
        {activeTab === 'quick' && <QuickStart />}
        {activeTab === 'routines' && <PresetList />}
        {activeTab === 'settings' && <Settings />}
      </main>

      {/* Floating Active Mini-Player */}
      <MiniPlayer />

      {/* Immersive Fullscreen Visualizer Modal */}
      {isVisualizerOpen && <TimerVisualizer />}
    </div>
  );
};

export function App() {
  return (
    <SettingsProvider>
      <PresetsProvider>
        <TimerProvider>
          <MainShell />
        </TimerProvider>
      </PresetsProvider>
    </SettingsProvider>
  );
}

export default App;

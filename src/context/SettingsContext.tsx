import React, { createContext, useContext, useEffect, useState } from 'react';
import type { PaletteOption, SoundId, ThemeMode, UserSettings } from '../types';
import { CURATED_PALETTES, DEFAULT_PALETTE } from '../core/palettes';
import { StorageService } from '../core/storage';
import { audioController } from '../core/audio';
import { notificationController } from '../core/notifications';

interface SettingsContextType {
  settings: UserSettings;
  currentPalette: PaletteOption;
  activeFocusColor: string;
  activeBreakColor: string;
  updateThemeMode: (mode: ThemeMode) => void;
  updatePalette: (paletteId: string) => void;
  updateCustomColors: (focusColor?: string, breakColor?: string) => void;
  updateFocusSound: (soundId: SoundId) => void;
  updateBreakSound: (soundId: SoundId) => void;
  toggleSound: (enabled: boolean) => void;
  updateVolume: (volume: number) => void;
  toggleNotifications: (enabled: boolean) => Promise<boolean>;
  previewSound: (soundId: SoundId) => void;
}

const SettingsContext = createContext<SettingsContextType | null>(null);

export const SettingsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [settings, setSettings] = useState<UserSettings>(() => StorageService.getSettings());

  const currentPalette =
    CURATED_PALETTES.find((p) => p.id === settings.selectedPaletteId) || DEFAULT_PALETTE;

  const activeFocusColor = settings.customFocusColor || currentPalette.focusColor;
  const activeBreakColor = settings.customBreakColor || currentPalette.breakColor;

  // Sync theme mode with DOM
  useEffect(() => {
    const root = document.documentElement;
    const isDark =
      settings.themeMode === 'dark' ||
      (settings.themeMode === 'system' &&
        window.matchMedia('(prefers-color-scheme: dark)').matches);

    if (isDark) {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }

    // Set CSS color variables for dynamic theme adaptation
    root.style.setProperty('--color-focus', activeFocusColor);
    root.style.setProperty('--color-break', activeBreakColor);
    root.style.setProperty('--color-accent', currentPalette.accentColor);
    root.style.setProperty('--color-glow', `${activeFocusColor}55`);
  }, [settings.themeMode, activeFocusColor, activeBreakColor, currentPalette.accentColor]);

  // Persist settings whenever changed
  const save = (newSettings: UserSettings) => {
    setSettings(newSettings);
    StorageService.saveSettings(newSettings);
  };

  const updateThemeMode = (mode: ThemeMode) => {
    save({ ...settings, themeMode: mode });
  };

  const updatePalette = (paletteId: string) => {
    save({
      ...settings,
      selectedPaletteId: paletteId,
      customFocusColor: undefined,
      customBreakColor: undefined,
    });
  };

  const updateCustomColors = (focusColor?: string, breakColor?: string) => {
    save({
      ...settings,
      customFocusColor: focusColor ?? settings.customFocusColor,
      customBreakColor: breakColor ?? settings.customBreakColor,
    });
  };

  const updateFocusSound = (soundId: SoundId) => {
    save({ ...settings, focusSoundId: soundId });
  };

  const updateBreakSound = (soundId: SoundId) => {
    save({ ...settings, breakSoundId: soundId });
  };

  const toggleSound = (enabled: boolean) => {
    save({ ...settings, soundEnabled: enabled });
  };

  const updateVolume = (volume: number) => {
    save({ ...settings, soundVolume: volume });
  };

  const toggleNotifications = async (enabled: boolean): Promise<boolean> => {
    if (enabled) {
      const granted = await notificationController.requestPermission();
      if (!granted) {
        save({ ...settings, notificationsEnabled: false });
        return false;
      }
    }
    save({ ...settings, notificationsEnabled: enabled });
    return true;
  };

  const previewSound = (soundId: SoundId) => {
    audioController.playSound(soundId, settings.soundVolume);
  };

  return (
    <SettingsContext.Provider
      value={{
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
      }}
    >
      {children}
    </SettingsContext.Provider>
  );
};

export const useSettings = (): SettingsContextType => {
  const ctx = useContext(SettingsContext);
  if (!ctx) throw new Error('useSettings must be used within SettingsProvider');
  return ctx;
};

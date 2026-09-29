import type { RoutinePreset, UserSettings, RoutineLog } from '../types';

const STORAGE_KEYS = {
  PRESETS: 'pace_presets_v2',
  SETTINGS: 'pace_settings_v2',
  LOGS: 'pace_routine_logs_v2',
};

export const DEFAULT_PRESETS: RoutinePreset[] = [
  {
    id: 'default_pomodoro',
    name: 'Classic Pomodoro',
    description: '25 min focus followed by 5 min restful recovery.',
    iterations: 4,
    createdAt: new Date().toISOString(),
    phases: [
      {
        id: 'pomo_focus',
        type: 'focus',
        name: 'Focus Block',
        durationInSeconds: 25 * 60,
      },
      {
        id: 'pomo_break',
        type: 'shortBreak',
        name: 'Short Break',
        durationInSeconds: 5 * 60,
      },
    ],
  },
  {
    id: 'default_ultradian',
    name: 'Ultradian Deep Work',
    description: '90 min deep cognitive session with 20 min decompression.',
    iterations: 2,
    createdAt: new Date(Date.now() - 60000).toISOString(),
    phases: [
      {
        id: 'ultra_focus',
        type: 'focus',
        name: 'Deep Flow',
        durationInSeconds: 90 * 60,
      },
      {
        id: 'ultra_break',
        type: 'longBreak',
        name: 'Restorative Break',
        durationInSeconds: 20 * 60,
      },
    ],
  },
  {
    id: 'default_tabata',
    name: 'Tabata High Intensity',
    description: '8 rounds: 10s warmup prep, 20s maximum effort, 10s recovery.',
    iterations: 8,
    isCustomSequence: true,
    createdAt: new Date(Date.now() - 120000).toISOString(),
    phases: [
      {
        id: 'tabata_prep',
        type: 'custom',
        name: 'Warmup / Prep',
        durationInSeconds: 10,
        color: '#F4A261',
      },
      {
        id: 'tabata_sprint',
        type: 'focus',
        name: 'Sprint / Push',
        durationInSeconds: 20,
        color: '#E63946',
      },
      {
        id: 'tabata_rest',
        type: 'shortBreak',
        name: 'Recovery Rest',
        durationInSeconds: 10,
        color: '#2A9D8F',
      },
    ],
  },
  {
    id: 'default_quick_stretch',
    name: 'Desk Reset & Stretch',
    description: 'Short 7-minute posture recharge and eye relaxation.',
    iterations: 3,
    createdAt: new Date(Date.now() - 180000).toISOString(),
    phases: [
      {
        id: 'stretch_work',
        type: 'focus',
        name: 'Active Reset',
        durationInSeconds: 7 * 60,
      },
      {
        id: 'stretch_rest',
        type: 'shortBreak',
        name: 'Hydrate & Breathe',
        durationInSeconds: 2 * 60,
      },
    ],
  },
];

export const DEFAULT_SETTINGS: UserSettings = {
  themeMode: 'system',
  selectedPaletteId: 'pace_pulse',
  focusSoundId: 'beep',
  breakSoundId: 'temple_bell',
  soundEnabled: true,
  soundVolume: 0.85,
  notificationsEnabled: true,
};

export class StorageService {
  static getPresets(): RoutinePreset[] {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.PRESETS);
      if (!data) {
        this.savePresets(DEFAULT_PRESETS);
        return DEFAULT_PRESETS;
      }
      return JSON.parse(data) as RoutinePreset[];
    } catch {
      return DEFAULT_PRESETS;
    }
  }

  static savePresets(presets: RoutinePreset[]): void {
    try {
      localStorage.setItem(STORAGE_KEYS.PRESETS, JSON.stringify(presets));
    } catch (e) {
      console.warn('Storage savePresets error:', e);
    }
  }

  static getSettings(): UserSettings {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.SETTINGS);
      if (!data) {
        this.saveSettings(DEFAULT_SETTINGS);
        return DEFAULT_SETTINGS;
      }
      return { ...DEFAULT_SETTINGS, ...JSON.parse(data) };
    } catch {
      return DEFAULT_SETTINGS;
    }
  }

  static saveSettings(settings: UserSettings): void {
    try {
      localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(settings));
    } catch (e) {
      console.warn('Storage saveSettings error:', e);
    }
  }

  static getRoutineLogs(): RoutineLog[] {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.LOGS);
      return data ? (JSON.parse(data) as RoutineLog[]) : [];
    } catch {
      return [];
    }
  }

  static saveRoutineLog(log: RoutineLog): void {
    try {
      const logs = this.getRoutineLogs();
      logs.unshift(log);
      localStorage.setItem(STORAGE_KEYS.LOGS, JSON.stringify(logs.slice(0, 500)));
    } catch (e) {
      console.warn('Storage saveRoutineLog error:', e);
    }
  }

  static deleteRoutineLog(id: string): void {
    try {
      const logs = this.getRoutineLogs().filter((l) => l.id !== id);
      localStorage.setItem(STORAGE_KEYS.LOGS, JSON.stringify(logs));
    } catch (e) {
      console.warn('Storage deleteRoutineLog error:', e);
    }
  }

  static clearLogsForPreset(presetId: string): void {
    try {
      const logs = this.getRoutineLogs().filter((l) => l.presetId !== presetId);
      localStorage.setItem(STORAGE_KEYS.LOGS, JSON.stringify(logs));
    } catch (e) {
      console.warn('Storage clearLogsForPreset error:', e);
    }
  }

  static clearAllLogs(): void {
    try {
      localStorage.removeItem(STORAGE_KEYS.LOGS);
    } catch (e) {
      console.warn('Storage clearAllLogs error:', e);
    }
  }
}

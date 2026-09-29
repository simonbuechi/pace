import { describe, it, expect, beforeEach } from 'vitest';
import { StorageService, DEFAULT_PRESETS, DEFAULT_SETTINGS } from '../core/storage';
import type { RoutinePreset } from '../types';

describe('StorageService', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('returns default presets when local storage is empty', () => {
    const presets = StorageService.getPresets();
    expect(presets).toHaveLength(DEFAULT_PRESETS.length);
    expect(presets[0].name).toBe(DEFAULT_PRESETS[0].name);
  });

  it('saves and retrieves modified presets', () => {
    const custom: RoutinePreset[] = [
      {
        id: 'test_1',
        name: 'Custom Sprint',
        description: 'Test',
        iterations: 1,
        createdAt: new Date().toISOString(),
        phases: [
          { id: 'p1', type: 'focus', name: 'Work', durationInSeconds: 300 },
          { id: 'p2', type: 'shortBreak', name: 'Rest', durationInSeconds: 60 },
        ],
      },
    ];

    StorageService.savePresets(custom);
    const retrieved = StorageService.getPresets();
    expect(retrieved).toHaveLength(1);
    expect(retrieved[0].name).toBe('Custom Sprint');
  });

  it('saves and retrieves user settings', () => {
    const initial = StorageService.getSettings();
    expect(initial.selectedPaletteId).toBe(DEFAULT_SETTINGS.selectedPaletteId);

    StorageService.saveSettings({
      ...initial,
      selectedPaletteId: 'zen_matcha',
      soundEnabled: false,
    });

    const updated = StorageService.getSettings();
    expect(updated.selectedPaletteId).toBe('zen_matcha');
    expect(updated.soundEnabled).toBe(false);
  });

  it('saves, retrieves, and clears routine completion logs', () => {
    expect(StorageService.getRoutineLogs()).toHaveLength(0);

    const log1 = {
      id: 'log_1',
      presetId: 'default_pomodoro',
      presetName: 'Classic Pomodoro',
      completedAt: new Date().toISOString(),
      totalDurationInSeconds: 1800,
      cyclesCompleted: 4,
      focusDurationInSeconds: 1500,
      breakDurationInSeconds: 300,
    };

    const log2 = {
      id: 'log_2',
      presetId: 'default_tabata',
      presetName: 'Tabata',
      completedAt: new Date().toISOString(),
      totalDurationInSeconds: 320,
      cyclesCompleted: 8,
      focusDurationInSeconds: 160,
      breakDurationInSeconds: 160,
    };

    StorageService.saveRoutineLog(log1);
    StorageService.saveRoutineLog(log2);

    const logs = StorageService.getRoutineLogs();
    expect(logs).toHaveLength(2);
    expect(logs[0].id).toBe('log_2'); // newest first
    expect(logs[1].id).toBe('log_1');

    StorageService.clearLogsForPreset('default_pomodoro');
    const filtered = StorageService.getRoutineLogs();
    expect(filtered).toHaveLength(1);
    expect(filtered[0].presetId).toBe('default_tabata');

    StorageService.deleteRoutineLog('log_2');
    expect(StorageService.getRoutineLogs()).toHaveLength(0);
  });
});

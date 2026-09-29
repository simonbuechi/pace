import React, { createContext, useContext, useState } from 'react';
import type { RoutinePreset, RoutineLog } from '../types';
import { StorageService } from '../core/storage';
import { syncController } from '../core/sync';

interface PresetsContextType {
  presets: RoutinePreset[];
  savePreset: (preset: RoutinePreset) => void;
  deletePreset: (id: string) => void;
  duplicatePreset: (preset: RoutinePreset) => void;
  getPresetById: (id: string) => RoutinePreset | undefined;
  logs: RoutineLog[];
  addRoutineLog: (log: RoutineLog) => void;
  deleteRoutineLog: (logId: string) => void;
  clearLogsForPreset: (presetId: string) => void;
  getLogsForPreset: (presetId: string) => RoutineLog[];
}

const PresetsContext = createContext<PresetsContextType | null>(null);

export const PresetsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [presets, setPresets] = useState<RoutinePreset[]>(() => StorageService.getPresets());
  const [logs, setLogs] = useState<RoutineLog[]>(() => StorageService.getRoutineLogs());

  const persist = (updated: RoutinePreset[]) => {
    setPresets(updated);
    StorageService.savePresets(updated);
    syncController.triggerSync();
  };

  const savePreset = (preset: RoutinePreset) => {
    const existingIndex = presets.findIndex((p) => p.id === preset.id);
    let updated: RoutinePreset[];

    if (existingIndex >= 0) {
      updated = [...presets];
      updated[existingIndex] = preset;
    } else {
      updated = [preset, ...presets];
    }

    persist(updated);
  };

  const deletePreset = (id: string) => {
    const updated = presets.filter((p) => p.id !== id);
    persist(updated);
  };

  const duplicatePreset = (preset: RoutinePreset) => {
    const clone: RoutinePreset = {
      ...preset,
      id: `preset_${Date.now()}_${Math.random().toString(36).substr(2, 4)}`,
      name: `${preset.name} (Copy)`,
      createdAt: new Date().toISOString(),
    };
    persist([clone, ...presets]);
  };

  const getPresetById = (id: string) => {
    return presets.find((p) => p.id === id);
  };

  const addRoutineLog = (log: RoutineLog) => {
    setLogs((prev) => [log, ...prev]);
    StorageService.saveRoutineLog(log);
  };

  const deleteRoutineLog = (logId: string) => {
    setLogs((prev) => prev.filter((l) => l.id !== logId));
    StorageService.deleteRoutineLog(logId);
  };

  const clearLogsForPreset = (presetId: string) => {
    setLogs((prev) => prev.filter((l) => l.presetId !== presetId));
    StorageService.clearLogsForPreset(presetId);
  };

  const getLogsForPreset = (presetId: string) => {
    return logs.filter((l) => l.presetId === presetId);
  };

  return (
    <PresetsContext.Provider
      value={{
        presets,
        savePreset,
        deletePreset,
        duplicatePreset,
        getPresetById,
        logs,
        addRoutineLog,
        deleteRoutineLog,
        clearLogsForPreset,
        getLogsForPreset,
      }}
    >
      {children}
    </PresetsContext.Provider>
  );
};

export const usePresets = (): PresetsContextType => {
  const ctx = useContext(PresetsContext);
  if (!ctx) throw new Error('usePresets must be used within PresetsProvider');
  return ctx;
};

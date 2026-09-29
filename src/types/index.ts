export type IntervalPhaseType = 'focus' | 'shortBreak' | 'longBreak' | 'custom';

export interface IntervalPhase {
  id: string;
  type: IntervalPhaseType;
  name: string;
  durationInSeconds: number;
  color?: string;
  soundId?: string;
}

export interface RoutinePreset {
  id: string;
  name: string;
  description: string;
  iterations: number;
  phases: IntervalPhase[];
  focusColor?: string;
  breakColor?: string;
  isCustomSequence?: boolean;
  createdAt: string;
}

export interface RoutineLog {
  id: string;
  presetId: string;
  presetName: string;
  completedAt: string; // ISO string
  totalDurationInSeconds: number;
  cyclesCompleted: number;
  focusDurationInSeconds: number;
  breakDurationInSeconds: number;
}

export interface TimerState {
  preset: RoutinePreset;
  currentIteration: number; // 1-indexed
  currentPhaseIndex: number; // 0-indexed
  remainingSeconds: number;
  totalPhaseSeconds: number;
  isRunning: boolean;
  isPaused: boolean;
  isCompleted: boolean;
}

export interface PaletteOption {
  id: string;
  name: string;
  focusColor: string;
  breakColor: string;
  accentColor: string;
  description: string;
}

export type SoundId = 'beep' | 'temple_bell' | 'digital_pulse';

export interface SoundOption {
  id: SoundId;
  name: string;
  description: string;
}

export type ThemeMode = 'system' | 'light' | 'dark';

export interface UserSettings {
  themeMode: ThemeMode;
  selectedPaletteId: string;
  customFocusColor?: string;
  customBreakColor?: string;
  focusSoundId: SoundId;
  breakSoundId: SoundId;
  soundEnabled: boolean;
  soundVolume: number; // 0.0 to 1.0
  notificationsEnabled: boolean;
}

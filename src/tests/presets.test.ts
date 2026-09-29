import { describe, it, expect } from 'vitest';
import { DEFAULT_PRESETS } from '../core/storage';
import { CURATED_PALETTES } from '../core/palettes';
import { APP_SOUNDS } from '../core/audio';

describe('Routines and Presets', () => {
  it('loads valid default presets with non-empty phases', () => {
    expect(DEFAULT_PRESETS.length).toBeGreaterThanOrEqual(4);

    DEFAULT_PRESETS.forEach((preset) => {
      expect(preset.id).toBeDefined();
      expect(preset.name).toBeTruthy();
      expect(preset.iterations).toBeGreaterThanOrEqual(1);
      expect(preset.phases.length).toBeGreaterThanOrEqual(2);

      const totalDuration = preset.phases.reduce((sum, p) => sum + p.durationInSeconds, 0);
      expect(totalDuration).toBeGreaterThan(0);
    });
  });

  it('correctly calculates Pomodoro total duration', () => {
    const pomo = DEFAULT_PRESETS.find((p) => p.id === 'default_pomodoro')!;
    expect(pomo).toBeDefined();

    // 25m + 5m = 30m * 4 = 120m = 7200s
    const perIteration = pomo.phases.reduce((sum, p) => sum + p.durationInSeconds, 0);
    expect(perIteration).toBe(30 * 60);

    const totalSeconds = perIteration * pomo.iterations;
    expect(totalSeconds).toBe(7200);
  });

  it('has Tabata with 3 phases and 8 iterations', () => {
    const tabata = DEFAULT_PRESETS.find((p) => p.id === 'default_tabata')!;
    expect(tabata).toBeDefined();
    expect(tabata.iterations).toBe(8);
    expect(tabata.phases.length).toBe(3);
    expect(tabata.phases[0].name).toContain('Warmup');
    expect(tabata.phases[1].name).toContain('Sprint');
    expect(tabata.phases[2].name).toContain('Rest');
  });

  it('validates curated palettes have focus and break colors', () => {
    expect(CURATED_PALETTES.length).toBe(6);
    CURATED_PALETTES.forEach((p) => {
      expect(p.focusColor).toMatch(/^#[0-9A-Fa-f]{6}$/);
      expect(p.breakColor).toMatch(/^#[0-9A-Fa-f]{6}$/);
      expect(p.accentColor).toMatch(/^#[0-9A-Fa-f]{6}$/);
    });
  });

  it('validates sound definitions for Beep, Temple Bell, and Digital Pulse', () => {
    expect(APP_SOUNDS.length).toBe(3);
    const ids = APP_SOUNDS.map((s) => s.id);
    expect(ids).toContain('beep');
    expect(ids).toContain('temple_bell');
    expect(ids).toContain('digital_pulse');
  });
});

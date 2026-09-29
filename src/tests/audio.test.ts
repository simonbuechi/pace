import { describe, it, expect, vi, beforeEach } from 'vitest';
import { audioController } from '../core/audio';

describe('AudioController Web Audio Synthesizer', () => {
  beforeEach(() => {
    const mockOscillator = {
      type: 'sine',
      frequency: {
        setValueAtTime: vi.fn(),
      },
      connect: vi.fn(),
      start: vi.fn(),
      stop: vi.fn(),
    };

    const mockGain = {
      gain: {
        setValueAtTime: vi.fn(),
        linearRampToValueAtTime: vi.fn(),
        exponentialRampToValueAtTime: vi.fn(),
      },
      connect: vi.fn(),
    };

    const mockFilter = {
      type: 'lowpass',
      frequency: {
        setValueAtTime: vi.fn(),
        exponentialRampToValueAtTime: vi.fn(),
      },
      connect: vi.fn(),
    };

    class MockAudioContext {
      currentTime = 100;
      state = 'running';
      destination = {};
      createOscillator = vi.fn(() => ({ ...mockOscillator }));
      createGain = vi.fn(() => ({ ...mockGain }));
      createBiquadFilter = vi.fn(() => ({ ...mockFilter }));
      resume = vi.fn().mockResolvedValue(undefined);
    }

    // @ts-expect-error Mocking window.AudioContext
    window.AudioContext = MockAudioContext;
  });

  it('plays standard beep without errors', () => {
    expect(() => audioController.playStandardBeep(0.8)).not.toThrow();
  });

  it('plays temple bell with harmonics without errors', () => {
    expect(() => audioController.playTempleBell(0.85)).not.toThrow();
  });

  it('plays digital pulse chirp without errors', () => {
    expect(() => audioController.playDigitalPulse(0.75)).not.toThrow();
  });

  it('routes playSound appropriately for each soundId', () => {
    expect(() => audioController.playSound('beep')).not.toThrow();
    expect(() => audioController.playSound('temple_bell')).not.toThrow();
    expect(() => audioController.playSound('digital_pulse')).not.toThrow();
  });
});

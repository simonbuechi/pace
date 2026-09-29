import type { SoundId, SoundOption } from '../types';

export const APP_SOUNDS: SoundOption[] = [
  {
    id: 'beep',
    name: 'Standard Beep',
    description: 'Crisp dual-tone prompt (880Hz & 1320Hz)',
  },
  {
    id: 'temple_bell',
    name: 'Temple Bell',
    description: '528Hz Solfeggio meditation chime with rich harmonic decay',
  },
  {
    id: 'digital_pulse',
    name: 'Digital Pulse',
    description: 'Modern 3-step ascending electronic chirp',
  },
];

class AudioController {
  private ctx: AudioContext | null = null;

  private getAudioContext(): AudioContext | null {
    if (typeof window === 'undefined') return null;

    if (!this.ctx) {
      const AudioCtxClass = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      if (AudioCtxClass) {
        this.ctx = new AudioCtxClass();
      }
    }

    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume().catch(() => {});
    }

    return this.ctx;
  }

  /**
   * Standard Beep: Dual-tone chime (880Hz -> 1320Hz)
   */
  playStandardBeep(volume = 0.85): void {
    const ctx = this.getAudioContext();
    if (!ctx) return;

    const now = ctx.currentTime;
    const masterGain = ctx.createGain();
    masterGain.gain.setValueAtTime(volume * 0.4, now);
    masterGain.connect(ctx.destination);

    // Tone 1: 880 Hz
    const osc1 = ctx.createOscillator();
    const gain1 = ctx.createGain();
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(880, now);

    gain1.gain.setValueAtTime(0, now);
    gain1.gain.linearRampToValueAtTime(0.7, now + 0.02);
    gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.18);

    osc1.connect(gain1);
    gain1.connect(masterGain);
    osc1.start(now);
    osc1.stop(now + 0.18);

    // Tone 2: 1320 Hz
    const osc2 = ctx.createOscillator();
    const gain2 = ctx.createGain();
    osc2.type = 'sine';
    osc2.frequency.setValueAtTime(1320, now + 0.14);

    gain2.gain.setValueAtTime(0, now + 0.14);
    gain2.gain.linearRampToValueAtTime(0.85, now + 0.16);
    gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.45);

    osc2.connect(gain2);
    gain2.connect(masterGain);
    osc2.start(now + 0.14);
    osc2.stop(now + 0.45);
  }

  /**
   * Temple Bell: 528Hz Solfeggio fundamental with additive harmonics & natural exponential decay
   */
  playTempleBell(volume = 0.85): void {
    const ctx = this.getAudioContext();
    if (!ctx) return;

    const now = ctx.currentTime;
    const duration = 2.2;

    const masterGain = ctx.createGain();
    masterGain.gain.setValueAtTime(volume * 0.5, now);

    // Subtle low-pass warm filter
    const filter = ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(2400, now);
    filter.frequency.exponentialRampToValueAtTime(800, now + duration);

    masterGain.connect(filter);
    filter.connect(ctx.destination);

    const harmonics = [
      { freq: 528, gain: 0.65, decayRate: 1.8 },   // Fundamental
      { freq: 792, gain: 0.22, decayRate: 2.2 },   // 1.5x harmonic
      { freq: 1056, gain: 0.32, decayRate: 2.5 },  // 2x octave
      { freq: 1584, gain: 0.14, decayRate: 3.0 },  // 3x overtone
      { freq: 2112, gain: 0.08, decayRate: 3.5 },  // Inharmonic sparkle
    ];

    harmonics.forEach(({ freq, gain, decayRate }) => {
      const osc = ctx.createOscillator();
      const g = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now);

      // Fast attack (3ms), exponential decay
      g.gain.setValueAtTime(0, now);
      g.gain.linearRampToValueAtTime(gain, now + 0.006);
      g.gain.exponentialRampToValueAtTime(0.0001, now + (duration / decayRate));

      osc.connect(g);
      g.connect(masterGain);

      osc.start(now);
      osc.stop(now + duration);
    });
  }

  /**
   * Digital Pulse: Fast modern 3-pulse frequency chirp
   */
  playDigitalPulse(volume = 0.85): void {
    const ctx = this.getAudioContext();
    if (!ctx) return;

    const now = ctx.currentTime;
    const masterGain = ctx.createGain();
    masterGain.gain.setValueAtTime(volume * 0.45, now);
    masterGain.connect(ctx.destination);

    const pulses = [
      { freq: 650, start: 0.0, len: 0.09 },
      { freq: 850, start: 0.11, len: 0.09 },
      { freq: 1150, start: 0.22, len: 0.14 },
    ];

    pulses.forEach(({ freq, start, len }) => {
      const osc = ctx.createOscillator();
      const g = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, now + start);

      g.gain.setValueAtTime(0, now + start);
      g.gain.linearRampToValueAtTime(0.75, now + start + 0.015);
      g.gain.exponentialRampToValueAtTime(0.001, now + start + len);

      osc.connect(g);
      g.connect(masterGain);

      osc.start(now + start);
      osc.stop(now + start + len);
    });
  }

  /**
   * Router to play by soundId
   */
  playSound(id: SoundId, volume = 0.85): void {
    switch (id) {
      case 'temple_bell':
        this.playTempleBell(volume);
        break;
      case 'digital_pulse':
        this.playDigitalPulse(volume);
        break;
      case 'beep':
      default:
        this.playStandardBeep(volume);
        break;
    }
  }
}

export const audioController = new AudioController();

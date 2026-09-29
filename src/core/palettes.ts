import type { PaletteOption } from '../types';

export const CURATED_PALETTES: PaletteOption[] = [
  {
    id: 'pace_pulse',
    name: 'Pace Pulse',
    focusColor: '#9123A6', // Signature royal violet
    breakColor: '#D7195F', // Signature crimson rose
    accentColor: '#FF2A85',
    description: 'Signature brand gradient matching the Pace Amigo emblem',
  },
  {
    id: 'sunset_ember',
    name: 'Sunset Ember',
    focusColor: '#DE5D35', // Warm terracotta flame
    breakColor: '#2E798A', // Calming ocean teal
    accentColor: '#FFB347',
    description: 'Invigorating warm focus with tranquil maritime rest',
  },
  {
    id: 'zen_matcha',
    name: 'Zen Matcha',
    focusColor: '#345E41', // Deep cedar forest green
    breakColor: '#6B8E4E', // Soft bamboo matcha
    accentColor: '#9BC19D',
    description: 'Grounded organic tones inspired by Kyoto gardens',
  },
  {
    id: 'nordic_slate',
    name: 'Nordic Slate',
    focusColor: '#2B3A42', // Deep slate graphite
    breakColor: '#4F6D7A', // Muted fjord mist
    accentColor: '#CBD5E1',
    description: 'Minimalist Scandinavian neutral aesthetic',
  },
  {
    id: 'cyber_horizon',
    name: 'Cyber Horizon',
    focusColor: '#7928CA', // Electric amethyst
    breakColor: '#0070F3', // Bright neon cobalt
    accentColor: '#FF0080',
    description: 'Vibrant modern high-contrast aesthetic',
  },
  {
    id: 'solar_amber',
    name: 'Solar Amber',
    focusColor: '#D95D16', // Deep amber
    breakColor: '#3F6E5D', // Sage woodland
    accentColor: '#F4A261',
    description: 'Warm invigorating citrus focus and soothing sage',
  },
];

export const DEFAULT_PALETTE = CURATED_PALETTES[0];

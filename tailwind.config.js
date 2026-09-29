/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', '-apple-system', 'BlinkMacSystemFont', '"Segoe UI"', 'Roboto', 'sans-serif'],
      },
      colors: {
        focus: 'var(--color-focus)',
        break: 'var(--color-break)',
        accent: 'var(--color-accent)',
        'surface-base': 'var(--color-surface-base)',
        'surface-card': 'var(--color-surface-card)',
        'surface-elevated': 'var(--color-surface-elevated)',
      },
      borderRadius: {
        '4xl': '2rem',
        '5xl': '2.5rem',
      },
      boxShadow: {
        'neu-raised-light': '5px 5px 14px rgba(160, 175, 196, 0.26), -5px -5px 14px rgba(255, 255, 255, 0.75)',
        'neu-raised-dark': '5px 5px 16px rgba(0, 0, 0, 0.38), -4px -4px 12px rgba(255, 255, 255, 0.02)',
        'neu-flat-light': '3px 3px 8px rgba(160, 175, 196, 0.2), -3px -3px 8px rgba(255, 255, 255, 0.7)',
        'neu-flat-dark': '3px 3px 8px rgba(0, 0, 0, 0.3), -2px -2px 6px rgba(255, 255, 255, 0.015)',
        'neu-inset-light': 'inset 2px 2px 5px rgba(160, 175, 196, 0.24), inset -2px -2px 5px rgba(255, 255, 255, 0.75)',
        'neu-inset-dark': 'inset 2px 2px 5px rgba(0, 0, 0, 0.42), inset -2px -2px 5px rgba(255, 255, 255, 0.02)',
        'neu-glow': '0 0 25px var(--color-glow)',
      },
      transitionTimingFunction: {
        'spring': 'cubic-bezier(0.34, 1.3, 0.64, 1)',
        'smooth': 'cubic-bezier(0.4, 0, 0.2, 1)',
      },
    },
  },
  plugins: [],
};

import React from 'react';

interface NeuSliderProps {
  value: number;
  min: number;
  max: number;
  step?: number;
  onChange: (val: number) => void;
  accentColor?: string;
  className?: string;
}

export const NeuSlider: React.FC<NeuSliderProps> = ({
  value,
  min,
  max,
  step = 1,
  onChange,
  accentColor = 'var(--color-focus)',
  className = '',
}) => {
  const percentage = Math.min(100, Math.max(0, ((value - min) / (max - min)) * 100));

  return (
    <div className={`relative flex items-center w-full h-8 ${className}`}>
      {/* Recessed Track */}
      <div className="relative w-full h-3 rounded-full neu-inset overflow-hidden bg-[var(--color-surface-base)]">
        {/* Filled Highlight */}
        <div
          className="h-full rounded-full transition-all duration-75"
          style={{
            width: `${percentage}%`,
            backgroundColor: accentColor,
          }}
        />
      </div>

      {/* Hidden Native Input */}
      <input
        type="range"
        min={min}
        max={max}
        step={step}
        value={value}
        onChange={(e) => onChange(Number(e.target.value))}
        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
      />

      {/* Tactile Thumb */}
      <div
        className="absolute w-6 h-6 rounded-full neu-flat bg-[var(--color-surface-card)] border-2 border-white dark:border-slate-700 pointer-events-none transform -translate-x-1/2 transition-transform duration-75 flex items-center justify-center shadow-md"
        style={{
          left: `${percentage}%`,
        }}
      >
        <div
          className="w-2 h-2 rounded-full"
          style={{ backgroundColor: accentColor }}
        />
      </div>
    </div>
  );
};

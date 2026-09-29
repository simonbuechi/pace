import React from 'react';

interface NeuChipProps {
  label: string;
  selected?: boolean;
  onClick?: () => void;
  accentColor?: string;
  className?: string;
}

export const NeuChip: React.FC<NeuChipProps> = ({
  label,
  selected = false,
  onClick,
  accentColor = 'var(--color-focus)',
  className = '',
}) => {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`px-4 py-2 rounded-2xl text-xs font-bold transition-all duration-200 select-none cursor-pointer flex items-center justify-center ${
        selected
          ? 'neu-inset text-white'
          : 'neu-flat text-[var(--color-text-main)] hover:neu-raised'
      } ${className}`}
      style={{
        backgroundColor: selected ? accentColor : 'var(--color-surface-card)',
      }}
    >
      {label}
    </button>
  );
};

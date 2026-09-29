import React from 'react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

interface NeuButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'subtle' | 'inset';
  size?: 'sm' | 'md' | 'lg' | 'icon';
  children: React.ReactNode;
  active?: boolean;
}

export const NeuButton: React.FC<NeuButtonProps> = ({
  variant = 'secondary',
  size = 'md',
  active = false,
  className,
  children,
  ...props
}) => {
  const sizeClasses = {
    sm: 'px-3.5 py-1.5 text-xs font-semibold rounded-xl gap-1.5',
    md: 'px-5 py-2.5 text-sm font-semibold rounded-2xl gap-2',
    lg: 'px-7 py-3.5 text-base font-bold rounded-2xl gap-2.5',
    icon: 'p-3 rounded-2xl aspect-square flex items-center justify-center',
  }[size];

  let variantClasses = '';

  if (active || variant === 'inset') {
    variantClasses = 'neu-inset text-[var(--color-focus)] bg-[var(--color-surface-base)]';
  } else if (variant === 'primary') {
    variantClasses =
      'bg-gradient-to-r from-[#9123A6] to-[#D7195F] text-white shadow-md shadow-[#9123A6]/20 hover:brightness-110 active:brightness-95 active:scale-[0.98] border border-white/20';
  } else if (variant === 'subtle') {
    variantClasses =
      'hover:bg-black/5 dark:hover:bg-white/5 text-[var(--color-text-muted)] hover:text-[var(--color-text-main)] active:scale-[0.98]';
  } else {
    variantClasses =
      'neu-flat bg-[var(--color-surface-card)] text-[var(--color-text-main)] hover:neu-raised active:neu-inset active:scale-[0.98]';
  }

  return (
    <button
      className={twMerge(
        clsx(
          'inline-flex items-center justify-center select-none transition-all duration-200 cursor-pointer disabled:opacity-45 disabled:pointer-events-none disabled:transform-none',
          sizeClasses,
          variantClasses,
          className
        )
      )}
      {...props}
    >
      {children}
    </button>
  );
};

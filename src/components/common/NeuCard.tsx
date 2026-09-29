import React from 'react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

interface NeuCardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'raised' | 'flat' | 'inset';
  className?: string;
  children: React.ReactNode;
}

export const NeuCard: React.FC<NeuCardProps> = ({
  variant = 'raised',
  className,
  children,
  ...props
}) => {
  const variantClass =
    variant === 'raised'
      ? 'neu-raised bg-[var(--color-surface-card)]'
      : variant === 'flat'
      ? 'neu-flat bg-[var(--color-surface-card)]'
      : 'neu-inset bg-[var(--color-surface-base)]';

  return (
    <div
      className={twMerge(
        clsx(
          'rounded-3xl p-6 transition-all duration-300 border border-[var(--color-border-subtle)]',
          variantClass,
          className
        )
      )}
      {...props}
    >
      {children}
    </div>
  );
};

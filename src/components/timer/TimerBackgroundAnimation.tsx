import React from 'react';
import type { BackgroundAnimationId } from '../../types';
import { ThreeBackgroundCanvas } from './ThreeBackgroundCanvas';

interface TimerBackgroundAnimationProps {
  animation: BackgroundAnimationId;
  isRunning: boolean;
  baseColor: string;
}

export const TimerBackgroundAnimation: React.FC<TimerBackgroundAnimationProps> = ({
  animation,
  isRunning,
  baseColor,
}) => {
  if (animation === 'none') {
    return null;
  }

  return (
    <div
      className={`absolute inset-0 pointer-events-none overflow-hidden transition-opacity duration-700 ${
        isRunning ? 'opacity-100' : 'opacity-40 [animation-play-state:paused]'
      }`}
      aria-hidden="true"
    >
      {/* 3D WebGL / Three.js GPU-Accelerated Visual Layer */}
      <ThreeBackgroundCanvas
        animation={animation}
        isRunning={isRunning}
        baseColor={baseColor}
      />

      {/* Atmospheric Secondary Ambient Bloom Shaders (Deepens color & mood) */}
      <div className="absolute inset-0 pointer-events-none mix-blend-overlay opacity-30 bg-gradient-to-t from-black/40 via-transparent to-white/10" />
    </div>
  );
};

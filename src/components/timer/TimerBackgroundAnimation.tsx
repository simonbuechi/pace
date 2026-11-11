import React from 'react';
import type { BackgroundAnimationId } from '../../types';

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
      {animation === 'breathing' && (
        <BreathingAnimation isRunning={isRunning} baseColor={baseColor} />
      )}
      {animation === 'orbs' && (
        <OrbsAnimation isRunning={isRunning} baseColor={baseColor} />
      )}
      {animation === 'aurora' && (
        <AuroraAnimation isRunning={isRunning} baseColor={baseColor} />
      )}
      {animation === 'stars' && (
        <StarsAnimation isRunning={isRunning} />
      )}
    </div>
  );
};

// 1. Breathing Pulse Animation
const BreathingAnimation: React.FC<{ isRunning: boolean; baseColor: string }> = ({
  isRunning,
}) => {
  return (
    <div className="absolute inset-0 flex items-center justify-center">
      {/* Outer soft expanding ring */}
      <div
        className={`absolute w-[600px] h-[600px] rounded-full bg-white/10 blur-3xl ${
          isRunning ? 'animate-breathe-slow' : ''
        }`}
      />
      {/* Middle resonant pulse ring */}
      <div
        className={`absolute w-[440px] h-[440px] rounded-full bg-white/15 blur-2xl ${
          isRunning ? 'animate-breathe-mid' : ''
        }`}
      />
      {/* Inner focused core halo */}
      <div
        className={`absolute w-[280px] h-[280px] rounded-full bg-white/20 blur-xl ${
          isRunning ? 'animate-breathe-core' : ''
        }`}
      />
    </div>
  );
};

// 2. Floating Orbs / Bubbles Animation
const ORB_CONFIGS = [
  { size: 280, left: '15%', top: '20%', duration: 18, delay: 0, opacity: 0.18 },
  { size: 340, left: '70%', top: '15%', duration: 22, delay: 3, opacity: 0.14 },
  { size: 220, left: '25%', top: '65%', duration: 16, delay: 5, opacity: 0.16 },
  { size: 300, left: '80%', top: '70%', duration: 24, delay: 1, opacity: 0.15 },
  { size: 180, left: '50%', top: '85%', duration: 20, delay: 7, opacity: 0.2 },
  { size: 200, left: '48%', top: '10%', duration: 19, delay: 4, opacity: 0.15 },
];

const OrbsAnimation: React.FC<{ isRunning: boolean; baseColor: string }> = ({
  isRunning,
}) => {
  return (
    <div className="absolute inset-0">
      {ORB_CONFIGS.map((orb, i) => (
        <div
          key={i}
          className={`absolute rounded-full blur-2xl bg-white ${
            isRunning ? 'animate-float-orb' : ''
          }`}
          style={{
            width: `${orb.size}px`,
            height: `${orb.size}px`,
            left: orb.left,
            top: orb.top,
            opacity: orb.opacity,
            animationDuration: `${orb.duration}s`,
            animationDelay: `${orb.delay}s`,
            animationPlayState: isRunning ? 'running' : 'paused',
          }}
        />
      ))}
    </div>
  );
};

// 3. Fluid Wave / Aurora Animation
const AuroraAnimation: React.FC<{ isRunning: boolean; baseColor: string }> = ({
  isRunning,
}) => {
  return (
    <div className="absolute inset-0">
      {/* Large sweeping gradient blobs that rotate and translate */}
      <div
        className={`absolute -top-1/4 -left-1/4 w-[150%] h-[150%] blur-3xl opacity-35 mix-blend-overlay ${
          isRunning ? 'animate-aurora-spin' : ''
        }`}
        style={{
          background:
            'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.45), transparent 50%), radial-gradient(circle at 70% 60%, rgba(255,255,255,0.3), transparent 45%), radial-gradient(circle at 40% 80%, rgba(255,255,255,0.35), transparent 50%)',
          animationPlayState: isRunning ? 'running' : 'paused',
        }}
      />
      {/* Secondary fluid counter-wave */}
      <div
        className={`absolute -bottom-1/3 -right-1/3 w-[140%] h-[140%] blur-3xl opacity-25 mix-blend-screen ${
          isRunning ? 'animate-aurora-reverse' : ''
        }`}
        style={{
          background:
            'radial-gradient(circle at 60% 40%, rgba(255,255,255,0.5), transparent 55%), radial-gradient(circle at 20% 70%, rgba(255,255,255,0.35), transparent 45%)',
          animationPlayState: isRunning ? 'running' : 'paused',
        }}
      />
    </div>
  );
};

// 4. Cosmic Starlight Animation
const STAR_CONFIGS = Array.from({ length: 32 }, (_, i) => ({
  id: i,
  left: `${(i * 19 + 7) % 96}%`,
  top: `${(i * 31 + 11) % 94}%`,
  size: (i % 3) + 2,
  duration: 3 + (i % 5) * 1.2,
  delay: (i % 7) * 0.7,
  opacity: 0.35 + (i % 5) * 0.15,
}));

const StarsAnimation: React.FC<{ isRunning: boolean }> = ({ isRunning }) => {
  return (
    <div className="absolute inset-0">
      {STAR_CONFIGS.map((star) => (
        <div
          key={star.id}
          className={`absolute rounded-full bg-white ${
            isRunning ? 'animate-twinkle-star' : ''
          }`}
          style={{
            left: star.left,
            top: star.top,
            width: `${star.size}px`,
            height: `${star.size}px`,
            opacity: star.opacity,
            boxShadow: `0 0 ${star.size * 3}px rgba(255, 255, 255, 0.8)`,
            animationDuration: `${star.duration}s`,
            animationDelay: `${star.delay}s`,
            animationPlayState: isRunning ? 'running' : 'paused',
          }}
        />
      ))}
    </div>
  );
};

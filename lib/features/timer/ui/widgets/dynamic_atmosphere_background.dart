import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pace_amigo/core/constants/app_colors.dart';

/// Representation of the ambient color palette and emotional rhythm for a timer phase.
class AtmospherePalette {
  final Color baseTop;
  final Color baseBottom;
  final Color orb1;
  final Color orb2;
  final Color orb3;
  final Color orb4;
  final Color haloColor;
  final Color moteColor;
  final double breathPeriod; // Respiration period in seconds

  const AtmospherePalette({
    required this.baseTop,
    required this.baseBottom,
    required this.orb1,
    required this.orb2,
    required this.orb3,
    required this.orb4,
    required this.haloColor,
    required this.moteColor,
    required this.breathPeriod,
  });

  /// Focus phase: deep cosmic amethyst & electric magenta with an intense, steady focus breath.
  static AtmospherePalette focus({Color? primaryFocus, Color? secondaryFocus}) {
    final p1 = primaryFocus ?? AppColors.primaryPurple;
    final p2 = secondaryFocus ?? AppColors.primaryMagenta;

    return AtmospherePalette(
      baseTop: const Color(0xFF0F051D),
      baseBottom: const Color(0xFF260B3B),
      orb1: p1,
      orb2: p2,
      orb3: const Color(0xFFFF2E7E),
      orb4: const Color(0xFF6B21A8),
      haloColor: p2,
      moteColor: const Color(0xFFFFD1EA),
      breathPeriod: 4.0, // 4-second meditative box breath
    );
  }

  /// Rest/Break phase: tranquil, restorative oceanic teal, soothing cyan and fresh seafoam.
  static AtmospherePalette rest({Color? accentColor}) {
    return AtmospherePalette(
      baseTop: const Color(0xFF06141D),
      baseBottom: const Color(0xFF0D2838),
      orb1: accentColor ?? const Color(0xFF00A896),
      orb2: const Color(0xFF028090),
      orb3: const Color(0xFF05668D),
      orb4: const Color(0xFF48CAE4),
      haloColor: const Color(0xFF02C39A),
      moteColor: const Color(0xFFCCFBF1),
      breathPeriod: 5.5, // 5.5-second deep restorative release breath
    );
  }

  /// Completed phase: warm golden celebratory triumph with amber radiance and champagne sparks.
  static AtmospherePalette completed() {
    return const AtmospherePalette(
      baseTop: Color(0xFF13111E),
      baseBottom: Color(0xFF2B1D0E),
      orb1: Color(0xFFF59E0B),
      orb2: Color(0xFFD97706),
      orb3: Color(0xFFEA580C),
      orb4: Color(0xFFFDE68A),
      haloColor: Color(0xFFF59E0B),
      moteColor: Color(0xFFFEF08A),
      breathPeriod: 4.5,
    );
  }

  static AtmospherePalette lerp(AtmospherePalette a, AtmospherePalette b, double t) {
    return AtmospherePalette(
      baseTop: Color.lerp(a.baseTop, b.baseTop, t) ?? b.baseTop,
      baseBottom: Color.lerp(a.baseBottom, b.baseBottom, t) ?? b.baseBottom,
      orb1: Color.lerp(a.orb1, b.orb1, t) ?? b.orb1,
      orb2: Color.lerp(a.orb2, b.orb2, t) ?? b.orb2,
      orb3: Color.lerp(a.orb3, b.orb3, t) ?? b.orb3,
      orb4: Color.lerp(a.orb4, b.orb4, t) ?? b.orb4,
      haloColor: Color.lerp(a.haloColor, b.haloColor, t) ?? b.haloColor,
      moteColor: Color.lerp(a.moteColor, b.moteColor, t) ?? b.moteColor,
      breathPeriod: (1 - t) * a.breathPeriod + t * b.breathPeriod,
    );
  }
}

/// Precomputed pseudo-random ambient particle mote.
class AmbientMote {
  final double seedX;
  final double seedY;
  final double speedY;
  final double driftX;
  final double frequency;
  final double phase;
  final double size;
  final double baseAlpha;

  const AmbientMote({
    required this.seedX,
    required this.seedY,
    required this.speedY,
    required this.driftX,
    required this.frequency,
    required this.phase,
    required this.size,
    required this.baseAlpha,
  });

  static List<AmbientMote> generate(int count) {
    final rand = math.Random(42); // Deterministic seed for consistent beauty
    return List.generate(count, (i) {
      return AmbientMote(
        seedX: rand.nextDouble(),
        seedY: rand.nextDouble(),
        speedY: 0.02 + rand.nextDouble() * 0.035, // gentle upward drift
        driftX: (rand.nextDouble() - 0.5) * 0.02,
        frequency: 0.8 + rand.nextDouble() * 1.5,
        phase: rand.nextDouble() * 2 * math.pi,
        size: 1.5 + rand.nextDouble() * 2.8,
        baseAlpha: 0.18 + rand.nextDouble() * 0.35,
      );
    });
  }
}

/// Dynamic, emotional, and organically generative atmosphere background.
///
/// Features:
/// - 4 floating plasma/aurora energy orbs moving along non-commensurate irrational harmonic Lissajous curves.
/// - Emotional color morphing across Focus, Rest, and Completed states.
/// - Ambient central breathing halo synchronized with human respiration cadence.
/// - Serene resting drift when paused/idle instead of freezing dead.
/// - 24 floating ambient stardust motes with organic turbulence.
class DynamicAtmosphereBackground extends StatefulWidget {
  final Widget child;
  final bool isRunning;
  final bool isPaused;
  final bool isCompleted;
  final bool isFocus;
  final double progress; // 0.0 to 1.0
  final Color? customFocusColor;
  final Color? customBreakColor;
  final bool isAnimationsEnabled;

  const DynamicAtmosphereBackground({
    super.key,
    required this.child,
    required this.isRunning,
    this.isPaused = false,
    this.isCompleted = false,
    this.isFocus = true,
    this.progress = 0.0,
    this.customFocusColor,
    this.customBreakColor,
    this.isAnimationsEnabled = true,
  });

  @override
  State<DynamicAtmosphereBackground> createState() =>
      _DynamicAtmosphereBackgroundState();
}

class _TickNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _DynamicAtmosphereBackgroundState extends State<DynamicAtmosphereBackground>
    with TickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  double _accumulatedTime = 0.0;

  // Emotional palette crossfade animation
  late final AnimationController _paletteTransitionController;
  late AtmospherePalette _previousPalette;
  late AtmospherePalette _targetPalette;

  // GPU repaint listenable (zero Widget tree rebuilds on 60/120Hz ticks)
  late final _TickNotifier _tickNotifier;
  late final Listenable _repaintListenable;

  // Stardust motes
  late final List<AmbientMote> _motes;

  double get accumulatedTime => _accumulatedTime;
  List<AmbientMote> get motes => _motes;

  AtmospherePalette get currentPalette {
    final t = _paletteTransitionController.value;
    return AtmospherePalette.lerp(_previousPalette, _targetPalette, t);
  }

  @override
  void initState() {
    super.initState();
    _motes = AmbientMote.generate(24);

    _targetPalette = _resolveCurrentPalette();
    _previousPalette = _targetPalette;

    _paletteTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..value = 1.0;

    _tickNotifier = _TickNotifier();
    _repaintListenable =
        Listenable.merge([_tickNotifier, _paletteTransitionController]);

    _ticker = createTicker(_onTick);
    if (widget.isAnimationsEnabled) {
      _ticker.start();
    }
  }

  AtmospherePalette _resolveCurrentPalette() {
    if (widget.isCompleted) {
      return AtmospherePalette.completed();
    }
    if (widget.isFocus) {
      return AtmospherePalette.focus(
        primaryFocus: widget.customFocusColor,
        secondaryFocus: widget.customBreakColor,
      );
    }
    return AtmospherePalette.rest(
      accentColor: widget.customBreakColor,
    );
  }

  @override
  void didUpdateWidget(covariant DynamicAtmosphereBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimationsEnabled != oldWidget.isAnimationsEnabled) {
      if (widget.isAnimationsEnabled) {
        if (!_ticker.isActive) _ticker.start();
      } else {
        if (_ticker.isActive) _ticker.stop();
        _tickNotifier.notify();
      }
    }


    final newPalette = _resolveCurrentPalette();
    final paletteChanged = widget.isCompleted != oldWidget.isCompleted ||
        widget.isFocus != oldWidget.isFocus ||
        widget.customFocusColor != oldWidget.customFocusColor ||
        widget.customBreakColor != oldWidget.customBreakColor;

    if (paletteChanged) {
      final currentProgress = _paletteTransitionController.value;
      _previousPalette = AtmospherePalette.lerp(
        _previousPalette,
        _targetPalette,
        currentProgress,
      );
      _targetPalette = newPalette;
      _paletteTransitionController.forward(from: 0.0);
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    final targetSpeed = widget.isRunning ? 1.0 : 0.35;
    _accumulatedTime += dt * targetSpeed;

    // Direct GPU layer repaint trigger — zero Widget tree rebuilds!
    _tickNotifier.notify();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _paletteTransitionController.dispose();
    _tickNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AtmospherePainter(
          backgroundState: this,
          repaint: _repaintListenable,
        ),
        child: widget.child,
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  final _DynamicAtmosphereBackgroundState backgroundState;

  _AtmospherePainter({
    required this.backgroundState,
    required super.repaint,
  });

  double get time => backgroundState.accumulatedTime;

  @override
  void paint(Canvas canvas, Size size) {
    final time = this.time;
    final palette = backgroundState.currentPalette;
    final motes = backgroundState.motes;

    final rect = Offset.zero & size;
    final minDim = math.min(size.width, size.height);

    // If background animations are disabled, render an elegant static gradient (0% GPU/CPU overhead)
    if (!backgroundState.widget.isAnimationsEnabled) {
      final staticPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.baseTop, palette.baseBottom],
        ).createShader(rect);
      canvas.drawRect(rect, staticPaint);
      return;
    }

    // 1. Base Atmospheric Depth Gradient
    // Gentle undulating gradient axis driven by incommensurate frequencies
    final gradAngle = 0.25 * math.pi + 0.15 * math.sin(time * 0.22);
    final gradBegin = Alignment(
      -math.cos(gradAngle),
      -math.sin(gradAngle),
    );
    final gradEnd = Alignment(
      math.cos(gradAngle),
      math.sin(gradAngle),
    );

    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: gradBegin,
        end: gradEnd,
        colors: [palette.baseTop, palette.baseBottom],
      ).createShader(rect);

    canvas.drawRect(rect, basePaint);

    // 2. Multi-Harmonic Floating Plasma Orbs
    // Four orbs with distinct, irrational harmonic frequency vectors (golden ratio & root ratios).
    _drawOrb(
      canvas: canvas,
      size: size,
      color: palette.orb1,
      baseNorm: const Offset(0.30, 0.35),
      rx: 0.26,
      ry: 0.22,
      freqX1: 0.37,
      freqX2: 0.618,
      freqY1: 0.29,
      freqY2: 0.51,
      phaseX: 0.4,
      phaseY: 1.1,
      baseRadius: minDim * 0.52,
      radiusFreq: 0.45,
      baseAlpha: 0.42,
    );

    _drawOrb(
      canvas: canvas,
      size: size,
      color: palette.orb2,
      baseNorm: const Offset(0.70, 0.65),
      rx: 0.24,
      ry: 0.25,
      freqX1: 0.43,
      freqX2: 0.707,
      freqY1: 0.33,
      freqY2: 0.48,
      phaseX: 2.3,
      phaseY: 0.7,
      baseRadius: minDim * 0.56,
      radiusFreq: 0.38,
      baseAlpha: 0.38,
    );

    _drawOrb(
      canvas: canvas,
      size: size,
      color: palette.orb3,
      baseNorm: const Offset(0.68, 0.28),
      rx: 0.22,
      ry: 0.20,
      freqX1: 0.52,
      freqX2: 0.31,
      freqY1: 0.41,
      freqY2: 0.63,
      phaseX: 3.1,
      phaseY: 2.4,
      baseRadius: minDim * 0.44,
      radiusFreq: 0.58,
      baseAlpha: 0.30,
    );

    _drawOrb(
      canvas: canvas,
      size: size,
      color: palette.orb4,
      baseNorm: const Offset(0.28, 0.75),
      rx: 0.25,
      ry: 0.18,
      freqX1: 0.31,
      freqX2: 0.57,
      freqY1: 0.46,
      freqY2: 0.39,
      phaseX: 1.8,
      phaseY: 3.8,
      baseRadius: minDim * 0.48,
      radiusFreq: 0.41,
      baseAlpha: 0.34,
    );

    // 3. Central Breathing Halo Pulse behind Timer Dial
    final dialCenter = Offset(size.width * 0.5, size.height * 0.48);
    final breathCycle = (2 * math.pi * time) / palette.breathPeriod;
    // Organic asymmetric breath: smoother inhalation, gentle floating pause, relaxing exhale
    final breathVal = math.sin(breathCycle);
    final haloRadius = (minDim * 0.45) * (1.0 + 0.12 * breathVal);
    final haloAlpha = (0.24 + 0.10 * breathVal).clamp(0.08, 0.45);

    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          palette.haloColor.withValues(alpha: haloAlpha),
          palette.haloColor.withValues(alpha: haloAlpha * 0.45),
          palette.haloColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: dialCenter, radius: haloRadius));

    canvas.drawCircle(dialCenter, haloRadius, haloPaint);

    // 4. Ambient Floating Motes / Stardust
    final motePaint = Paint()..style = PaintingStyle.fill;
    for (final m in motes) {
      // Upward drift with horizontal sine turbulence
      final y = (m.seedY - m.speedY * time) % 1.0;
      final xOffset = 0.04 * math.sin(time * m.frequency + m.phase);
      final x = (m.seedX + m.driftX * time + xOffset) % 1.0;

      final px = x * size.width;
      final py = y * size.height;

      // Alpha breathing
      final alphaPulse = 0.6 + 0.4 * math.sin(time * m.frequency * 1.6 + m.phase);
      final currentAlpha = (m.baseAlpha * alphaPulse).clamp(0.04, 0.65);

      motePaint.color = palette.moteColor.withValues(alpha: currentAlpha);
      canvas.drawCircle(Offset(px, py), m.size, motePaint);
    }
  }

  void _drawOrb({
    required Canvas canvas,
    required Size size,
    required Color color,
    required Offset baseNorm,
    required double rx,
    required double ry,
    required double freqX1,
    required double freqX2,
    required double freqY1,
    required double freqY2,
    required double phaseX,
    required double phaseY,
    required double baseRadius,
    required double radiusFreq,
    required double baseAlpha,
  }) {
    // Multi-harmonic Lissajous calculation
    final normX = baseNorm.dx +
        rx * (0.65 * math.sin(time * freqX1 + phaseX) +
            0.35 * math.cos(time * freqX2 + phaseX * 1.5));
    final normY = baseNorm.dy +
        ry * (0.65 * math.cos(time * freqY1 + phaseY) +
            0.35 * math.sin(time * freqY2 + phaseY * 1.3));

    final center = Offset(normX * size.width, normY * size.height);
    final radFactor = 1.0 + 0.16 * math.sin(time * radiusFreq + phaseX);
    final radius = baseRadius * radFactor;

    final alphaFactor = 1.0 + 0.18 * math.cos(time * (radiusFreq * 0.9) + phaseY);
    final alpha = (baseAlpha * alphaFactor).clamp(0.08, 0.70);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: alpha * 0.55),
          color.withValues(alpha: alpha * 0.18),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.40, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.backgroundState != backgroundState;
  }

}

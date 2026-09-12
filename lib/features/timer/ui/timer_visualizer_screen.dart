import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pace_amigo/features/timer/models/timer_state.dart';
import 'package:pace_amigo/features/timer/providers/timer_provider.dart';
import 'package:pace_amigo/features/settings/providers/settings_provider.dart';
import 'widgets/circular_timer_painter.dart';
import 'widgets/dynamic_atmosphere_background.dart';

class TimerVisualizerScreen extends ConsumerStatefulWidget {
  const TimerVisualizerScreen({super.key});

  @override
  ConsumerState<TimerVisualizerScreen> createState() =>
      _TimerVisualizerScreenState();
}

class _TimerVisualizerScreenState extends ConsumerState<TimerVisualizerScreen> {
  bool _controlsVisible = true;

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final settings = ref.watch(settingsProvider);

    final customFocusColor = settings.customFocusColorValue != null
        ? Color(settings.customFocusColorValue!)
        : null;
    final customBreakColor = settings.customBreakColorValue != null
        ? Color(settings.customBreakColorValue!)
        : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: DynamicAtmosphereBackground(
            isRunning: timerState.isRunning,
            isPaused: timerState.isPaused,
            isCompleted: timerState.isCompleted,
            isFocus: timerState.currentPhase.isFocus,
            progress: timerState.progress,
            customFocusColor: customFocusColor,
            customBreakColor: customBreakColor,
            isAnimationsEnabled: settings.backgroundAnimationsEnabled,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape =
                      constraints.maxWidth > constraints.maxHeight;

                  // Soft circular dial in the background
                  final maxDialSize = isLandscape
                      ? min(constraints.maxHeight * 0.90,
                          constraints.maxWidth * 0.90)
                      : min(constraints.maxWidth * 0.90,
                          constraints.maxHeight * 0.50);

                  return Stack(
                    children: [
                      // 1. Soft / Transparent Circular Progress Ring in the background
                      Center(
                        child: _buildSoftBackgroundCircle(
                          timerState,
                          maxDialSize,
                          isLandscape,
                        ),
                      ),

                      // 2. Hero Giant Time Display filling the whole display
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Phase pill badge
                            _buildPhaseHeader(timerState,
                                isLandscape: isLandscape),
                            SizedBox(height: isLandscape ? 4 : 14),

                            // Massive Time Text filling display
                            _buildGiantTimeDisplay(
                                timerState, constraints, isLandscape),

                            SizedBox(height: isLandscape ? 4 : 14),

                            // Status badge and cycle indicators
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (timerState.isPaused)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'PAUSED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ),
                                _buildIterationPills(timerState),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 3. Top App Bar (Exit / Title / Minimalist toggle)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        top: _controlsVisible ? (isLandscape ? 10 : 16) : -80,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.25),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                timerState.preset.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.25),
                                foregroundColor: Colors.white,
                              ),
                              icon: Icon(
                                _controlsVisible
                                    ? Icons.fullscreen_rounded
                                    : Icons.fullscreen_exit_rounded,
                              ),
                              onPressed: _toggleControls,
                            ),
                          ],
                        ),
                      ),

                      // 4. Bottom Controls (Skip prev, Play/Pause, Skip next, Reset)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        bottom:
                            _controlsVisible ? (isLandscape ? 10 : 24) : -110,
                        left: 20,
                        right: 20,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: RepaintBoundary(
                              child: _buildControlBar(timerState),
                            ),
                          ),
                        ),
                      ),

                      // 5. Completed State Modal / Banner
                      if (timerState.isCompleted)
                        _buildCompletionOverlay(timerState),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseHeader(TimerState timerState, {bool isLandscape = false}) {
    final phase = timerState.currentPhase;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 14 : 20,
        vertical: isLandscape ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            phase.isFocus ? Icons.flash_on_rounded : Icons.spa_rounded,
            color: Colors.white,
            size: isLandscape ? 15 : 18,
          ),
          const SizedBox(width: 6),
          Text(
            phase.name.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: isLandscape ? 11 : 13,
              letterSpacing: isLandscape ? 1.5 : 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftBackgroundCircle(
      TimerState timerState, double size, bool isLandscape) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          size: Size(size, size),
          painter: CircularTimerPainter(
            progress: timerState.progress,
            trackColor: Colors.white.withValues(alpha: 0.08),
            progressColor: Colors.white.withValues(alpha: 0.28),
            strokeWidth: isLandscape ? 8.0 : 10.0,
          ),
        ),
      ),
    );
  }

  Widget _buildGiantTimeDisplay(
      TimerState timerState, BoxConstraints constraints, bool isLandscape) {
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;

    // Fill the display: in landscape allow wide width and height
    final targetWidth = isLandscape
        ? availableWidth * (_controlsVisible ? 0.88 : 0.95)
        : availableWidth * 0.94;
    final targetHeight = isLandscape
        ? availableHeight * (_controlsVisible ? 0.60 : 0.78)
        : availableHeight * 0.38;

    return RepaintBoundary(
      child: SizedBox(
        width: targetWidth,
        height: targetHeight,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Text(
            timerState.formattedRemainingTime,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 160,
              fontWeight: FontWeight.w800,
              letterSpacing: 4.0,
              fontFeatures: [FontFeature.tabularFigures()],
              height: 1.0,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIterationPills(TimerState timerState) {
    final total = timerState.preset.iterations;
    final current = timerState.currentIteration;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final cycleNum = index + 1;
        final isDone = cycleNum < current;
        final isCurrent = cycleNum == current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 26 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isDone
                ? Colors.white
                : isCurrent
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _buildControlBar(TimerState timerState) {
    final notifier = ref.read(timerProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 26),
            onPressed: () => notifier.reset(),
            tooltip: 'Reset',
          ),

          // Skip Previous
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded,
                color: Colors.white, size: 30),
            onPressed: () => notifier.skipPrevious(),
            tooltip: 'Previous Interval',
          ),

          // Play / Pause Main CTA
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                if (timerState.isRunning) {
                  notifier.pause();
                } else {
                  notifier.start();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(
                  timerState.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.black87,
                  size: 38,
                ),
              ),
            ),
          ),

          // Skip Next
          IconButton(
            icon: const Icon(Icons.skip_next_rounded,
                color: Colors.white, size: 30),
            onPressed: () => notifier.skipNext(),
            tooltip: 'Next Interval',
          ),

          // Distraction-free tip or mute
          IconButton(
            icon: Icon(
              ref.watch(settingsProvider).soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              final current = ref.read(settingsProvider).soundEnabled;
              ref.read(settingsProvider.notifier).toggleSound(!current);
            },
            tooltip: 'Toggle Sound',
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionOverlay(TimerState timerState) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFD700),
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Routine Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great work completing all ${timerState.preset.iterations} cycles of ${timerState.preset.name}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Restart Session'),
              onPressed: () {
                ref.read(timerProvider.notifier).reset();
                ref.read(timerProvider.notifier).start();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.8),
              ),
              child: const Text('Return to Home'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

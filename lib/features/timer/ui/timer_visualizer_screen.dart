import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pace_amigo/features/timer/models/timer_state.dart';
import 'package:pace_amigo/features/timer/providers/timer_provider.dart';
import 'package:pace_amigo/features/settings/providers/settings_provider.dart';
import 'widgets/circular_timer_painter.dart';

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
    final focusColor = ref.watch(activeFocusColorProvider);
    final breakColor = ref.watch(activeBreakColorProvider);

    // Determine current background color based on active interval phase
    final Color targetBgColor;
    if (timerState.isCompleted) {
      targetBgColor = const Color(0xFF1E293B); // Dark slate completion
    } else if (timerState.currentPhase.colorValue != null) {
      targetBgColor = Color(timerState.currentPhase.colorValue!);
    } else if (timerState.currentPhase.isFocus) {
      targetBgColor = focusColor;
    } else {
      targetBgColor = breakColor;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeInOutCubic,
            color: targetBgColor,
            child: SafeArea(
              child: Stack(
                children: [
                  // Subtle ambient background gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.1,
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.black.withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main Content: Phase Info, Circular Timer, Iteration counter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top header with routine name and phase badge
                      _buildPhaseHeader(timerState),

                      const SizedBox(height: 36),

                      // Circular Visualizer Dial
                      Center(
                        child: _buildCircularDial(timerState),
                      ),

                      const SizedBox(height: 36),

                      // Iteration / Cycle Pills
                      _buildIterationPills(timerState),
                    ],
                  ),

                  // Top App Bar (Exit / Title / Minimalist toggle)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    top: _controlsVisible ? 16 : -80,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.25),
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
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            timerState.preset.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.25),
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

                  // Bottom Controls (Skip prev, Play/Pause, Skip next, Reset)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    bottom: _controlsVisible ? 24 : -100,
                    left: 24,
                    right: 24,
                    child: _buildControlBar(timerState),
                  ),

                  // Completed State Modal / Banner
                  if (timerState.isCompleted) _buildCompletionOverlay(timerState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseHeader(TimerState timerState) {
    final phase = timerState.currentPhase;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                phase.isFocus
                    ? Icons.flash_on_rounded
                    : Icons.spa_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                phase.name.toUpperCase(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularDial(TimerState timerState) {
    const dialSize = 280.0;

    return SizedBox(
      width: dialSize,
      height: dialSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(dialSize, dialSize),
            painter: CircularTimerPainter(
              progress: timerState.progress,
              trackColor: Colors.white.withOpacity(0.15),
              progressColor: Colors.white,
              strokeWidth: 12.0,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timerState.formattedRemainingTime,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 58,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timerState.isRunning
                    ? 'IN PROGRESS'
                    : timerState.isPaused
                        ? 'PAUSED'
                        : 'READY',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ],
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
                    : Colors.white.withOpacity(0.25),
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
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
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
        color: Colors.black.withOpacity(0.85),
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
            Text(
              'Routine Complete!',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great work completing all ${timerState.preset.iterations} cycles of ${timerState.preset.name}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
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
                foregroundColor: Colors.white.withOpacity(0.8),
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

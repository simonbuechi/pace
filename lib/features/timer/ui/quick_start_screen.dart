import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pace_amigo/core/constants/app_colors.dart';
import 'package:pace_amigo/features/presets/models/routine_preset.dart';
import 'package:pace_amigo/features/timer/models/interval_phase.dart';
import 'package:pace_amigo/features/timer/models/timer_state.dart';
import 'package:pace_amigo/features/timer/providers/timer_provider.dart';
import 'timer_visualizer_screen.dart';

/// Minimalist, ultra-clean Quick Start screen for Pace.
/// Fits 100% on the screen with zero scrolling, spacious ergonomics,
/// and effortless instant launch.
class QuickStartScreen extends ConsumerStatefulWidget {
  const QuickStartScreen({super.key});

  @override
  ConsumerState<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends ConsumerState<QuickStartScreen> {
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _cycles = 4;

  static const List<int> _focusPresets = [15, 25, 45, 60];

  void _setFocus(int mins) {
    mins = mins.clamp(1, 180);
    if (_focusMinutes != mins) {
      HapticFeedback.selectionClick();
      setState(() => _focusMinutes = mins);
    }
  }

  void _adjustFocus(int delta) => _setFocus(_focusMinutes + delta);

  void _setBreak(int mins) {
    mins = mins.clamp(1, 60);
    if (_breakMinutes != mins) {
      HapticFeedback.selectionClick();
      setState(() => _breakMinutes = mins);
    }
  }

  void _adjustBreak(int delta) => _setBreak(_breakMinutes + delta);

  void _setCycles(int cycles) {
    cycles = cycles.clamp(1, 16);
    if (_cycles != cycles) {
      HapticFeedback.selectionClick();
      setState(() => _cycles = cycles);
    }
  }

  void _adjustCycles(int delta) => _setCycles(_cycles + delta);

  void _startSession() {
    HapticFeedback.mediumImpact();

    final preset = RoutinePreset.createStandard(
      id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Quick Start (${_focusMinutes}m / ${_breakMinutes}m)',
      description:
          '$_focusMinutes min focus • $_breakMinutes min break • $_cycles cycles',
      focusMinutes: _focusMinutes,
      focusSeconds: 0,
      breakMinutes: _breakMinutes,
      breakSeconds: 0,
      iterations: _cycles,
    );

    ref.read(timerProvider.notifier).loadPreset(preset);
    ref.read(timerProvider.notifier).start();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TimerVisualizerScreen()),
    );
  }

  void _showCustomMinutesDialog({required bool isFocus}) {
    HapticFeedback.lightImpact();
    final current = isFocus ? _focusMinutes : _breakMinutes;
    final controller = TextEditingController(text: '$current');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isFocus ? 'Focus Duration' : 'Break Duration',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          decoration: InputDecoration(
            suffixText: 'min',
            hintText: '$current',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                if (isFocus) {
                  _setFocus(val);
                } else {
                  _setBreak(val);
                }
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timerState = ref.watch(timerProvider);
    final isTimerActive =
        (timerState.isRunning || timerState.isPaused) && !timerState.isCompleted;

    // Planned calculations
    final totalSessionMinutes = (_focusMinutes + _breakMinutes) * _cycles;
    final hours = totalSessionMinutes ~/ 60;
    final mins = totalSessionMinutes % 60;
    final durationText = hours > 0
        ? '${hours}h ${mins.toString().padLeft(2, '0')}m'
        : '${mins}m';

    final finishTime =
        DateTime.now().add(Duration(minutes: totalSessionMinutes));
    final finishStr =
        '${finishTime.hour.toString().padLeft(2, '0')}:${finishTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Active Session Mini Pill (If running)
                          if (isTimerActive) ...[
                            _buildActiveBanner(context, timerState, isDark),
                            const SizedBox(height: 14),
                          ],

                          const Spacer(flex: 1),

                          // 3. Hero Focus Duration Selector
                          Column(
                            children: [
                              Text(
                                'Focus Duration',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Big Tappable Number + Steppers
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStepBtn(
                                    icon: Icons.remove_rounded,
                                    onTap: () => _adjustFocus(-5),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _showCustomMinutesDialog(
                                        isFocus: true),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '$_focusMinutes',
                                            style: const TextStyle(
                                              fontSize: 72,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -3.0,
                                              fontFeatures: [
                                                FontFeature.tabularFigures()
                                              ],
                                              height: 1.0,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'min',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildStepBtn(
                                    icon: Icons.add_rounded,
                                    onTap: () => _adjustFocus(5),
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Preset Quick Pills (15m, 25m, 45m, 60m)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _focusPresets.map((m) {
                                  final isSelected = _focusMinutes == m;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: ChoiceChip(
                                      label: Text('${m}m'),
                                      selected: isSelected,
                                      onSelected: (_) => _setFocus(m),
                                      showCheckmark: false,
                                      selectedColor: AppColors.primaryPurple,
                                      backgroundColor: isDark
                                          ? const Color(0xFF1E1A29)
                                          : Colors.grey.shade200,
                                      labelStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: isSelected
                                              ? AppColors.primaryPurple
                                              : Colors.transparent,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                          const Spacer(flex: 2),

                          // 4. Compact Dual Row: Break & Cycles
                          Row(
                            children: [
                              Expanded(
                                child: _buildPillControl(
                                  context: context,
                                  icon: Icons.spa_rounded,
                                  color: AppColors.primaryMagenta,
                                  label: 'Break',
                                  valueNumber: '$_breakMinutes',
                                  valueUnit: 'min',
                                  onMinus: () => _adjustBreak(-1),
                                  onPlus: () => _adjustBreak(1),
                                  onTap: () => _showCustomMinutesDialog(
                                      isFocus: false),
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPillControl(
                                  context: context,
                                  icon: Icons.repeat_rounded,
                                  color: AppColors.primaryPurple,
                                  label: 'Cycles',
                                  valueNumber: '$_cycles',
                                  valueUnit: 'sets',
                                  onMinus: () => _adjustCycles(-1),
                                  onPlus: () => _adjustCycles(1),
                                  onTap: null,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // 5. Minimalist 1-Line Forecast
                          Text(
                            '$durationText total across $_cycles cycles • Done at $finishStr',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.8),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Spacer(flex: 1),

                          // 6. Clean Start Session Button
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPurple
                                      .withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
                                onTap: _startSession,
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_arrow_rounded,
                                          color: Colors.white, size: 28),
                                      SizedBox(width: 6),
                                      Text(
                                        'Start Session',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillControl({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required String valueNumber,
    required String valueUnit,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191624) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTinyStepBtn(
                icon: Icons.remove_rounded,
                onTap: onMinus,
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            valueNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            valueUnit,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildTinyStepBtn(
                icon: Icons.add_rounded,
                onTap: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mini active status banner if timer is active in background
  Widget _buildActiveBanner(
      BuildContext context, TimerState timerState, bool isDark) {
    final isFocus = timerState.currentPhase.type == IntervalPhaseType.focus;
    final color = isFocus ? AppColors.primaryPurple : AppColors.primaryMagenta;
    final mins = timerState.remainingSeconds ~/ 60;
    final secs = timerState.remainingSeconds % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(isFocus ? Icons.flash_on_rounded : Icons.spa_rounded,
              size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            isFocus ? 'FOCUS SESSION' : 'REST BREAK',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              timerState.isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 20,
              color: color,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (timerState.isRunning) {
                ref.read(timerProvider.notifier).pause();
              } else {
                ref.read(timerProvider.notifier).resume();
              }
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(Icons.fullscreen_rounded, size: 22, color: color),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TimerVisualizerScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }

  Widget _buildTinyStepBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pace_amigo/features/presets/models/routine_preset.dart';
import 'package:pace_amigo/features/timer/providers/timer_provider.dart';
import 'timer_visualizer_screen.dart';

class QuickStartScreen extends ConsumerStatefulWidget {
  const QuickStartScreen({super.key});

  @override
  ConsumerState<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends ConsumerState<QuickStartScreen> {
  int _focusMinutes = 25;
  int _focusSeconds = 0;
  int _breakMinutes = 5;
  int _breakSeconds = 0;
  int _iterations = 4;

  void _startQuickSession() {
    final preset = RoutinePreset.createStandard(
      id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Quick Start',
      description: '$_focusMinutes min focus / $_breakMinutes min break',
      focusMinutes: _focusMinutes,
      focusSeconds: _focusSeconds,
      breakMinutes: _breakMinutes,
      breakSeconds: _breakSeconds,
      iterations: _iterations,
    );

    ref.read(timerProvider.notifier).loadPreset(preset);
    ref.read(timerProvider.notifier).start();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TimerVisualizerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSec = ((_focusMinutes * 60 + _focusSeconds) +
            (_breakMinutes * 60 + _breakSeconds)) *
        _iterations;
    final totalMin = totalSec ~/ 60;
    final remainingSec = totalSec % 60;
    final formattedTotal = remainingSec > 0
        ? '$totalMin min $remainingSec s'
        : '$totalMin minutes';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Quick Start',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set your focus & break targets and start immediately.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),

          // Focus Duration Card
          _buildDurationCard(
            context,
            title: 'Focus Duration',
            icon: Icons.flash_on_rounded,
            accentColor: theme.colorScheme.primary,
            minutes: _focusMinutes,
            seconds: _focusSeconds,
            presetMinutes: [0, 15, 25, 45, 60],
            onChanged: (m, s) => setState(() {
              _focusMinutes = m;
              _focusSeconds = s;
            }),
          ),

          const SizedBox(height: 20),

          // Break Duration Card
          _buildDurationCard(
            context,
            title: 'Break Duration',
            icon: Icons.spa_rounded,
            accentColor: theme.colorScheme.secondary,
            minutes: _breakMinutes,
            seconds: _breakSeconds,
            presetMinutes: [0, 3, 5, 10, 15],
            onChanged: (m, s) => setState(() {
              _breakMinutes = m;
              _breakSeconds = s;
            }),
          ),

          const SizedBox(height: 20),

          // Iterations Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.repeat_rounded,
                              color: theme.colorScheme.tertiary, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Interval Cycles',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$_iterations rounds',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [1, 2, 3, 4, 6, 8].map((count) {
                      final isSelected = count == _iterations;
                      return ChoiceChip(
                        label: Text('$count'),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _iterations = count);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Session Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined,
                    color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Planned Session',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '$formattedTotal across $_iterations cycles',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Primary Launch CTA
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _startQuickSession,
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text(
                'Start Session',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required int minutes,
    required int seconds,
    required List<int> presetMinutes,
    required void Function(int min, int sec) onChanged,
  }) {
    final theme = Theme.of(context);

    String durationText;
    if (minutes == 0) {
      durationText = '${seconds}s';
    } else if (seconds == 0) {
      durationText = '$minutes min';
    } else {
      durationText = '$minutes min ${seconds}s';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: accentColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    durationText,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick preset chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presetMinutes.map((val) {
                final isSelected = val == 0 ? (minutes == 0 && seconds == 30) : (val == minutes && seconds == 0);
                return ChoiceChip(
                  label: Text(val == 0 ? '30s' : '$val m'),
                  selected: isSelected,
                  onSelected: (s) {
                    if (s) {
                      if (val == 0) {
                        onChanged(0, 30);
                      } else {
                        onChanged(val, 0);
                      }
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Minutes Slider
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'Minutes',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: minutes.toDouble().clamp(0.0, 90.0),
                    min: 0,
                    max: 90,
                    divisions: 90,
                    label: '$minutes m',
                    onChanged: (val) {
                      final newMin = val.round();
                      final newSec = (newMin == 0 && seconds == 0) ? 15 : seconds;
                      onChanged(newMin, newSec);
                    },
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '$minutes m',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
            // Seconds Slider
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'Seconds',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: seconds.toDouble().clamp(0.0, 55.0),
                    min: 0,
                    max: 55,
                    divisions: 11,
                    label: '$seconds s',
                    onChanged: (val) {
                      final newSec = val.round();
                      final newMin = (minutes == 0 && newSec == 0) ? 1 : minutes;
                      onChanged(newMin, newSec);
                    },
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '$seconds s',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


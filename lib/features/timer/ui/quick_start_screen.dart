import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pace_amigo/core/constants/app_colors.dart';
import 'package:pace_amigo/features/presets/models/routine_preset.dart';
import 'package:pace_amigo/features/timer/providers/timer_provider.dart';
import 'timer_visualizer_screen.dart';

class QuickStartScreen extends ConsumerStatefulWidget {
  const QuickStartScreen({super.key});

  @override
  ConsumerState<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends ConsumerState<QuickStartScreen> {
  int _focusMinutes = 5;
  int _focusSeconds = 0;
  int _breakMinutes = 1;
  int _breakSeconds = 0;
  int _iterations = 4;

  late final TextEditingController _focusMinController;
  late final TextEditingController _focusSecController;
  late final TextEditingController _breakMinController;
  late final TextEditingController _breakSecController;
  late final TextEditingController _iterationsController;

  @override
  void initState() {
    super.initState();
    _focusMinController = TextEditingController(text: '$_focusMinutes');
    _focusSecController = TextEditingController(text: '$_focusSeconds');
    _breakMinController = TextEditingController(text: '$_breakMinutes');
    _breakSecController = TextEditingController(text: '$_breakSeconds');
    _iterationsController = TextEditingController(text: '$_iterations');
  }

  @override
  void dispose() {
    _focusMinController.dispose();
    _focusSecController.dispose();
    _breakMinController.dispose();
    _breakSecController.dispose();
    _iterationsController.dispose();
    super.dispose();
  }

  void _startQuickSession() {
    final focusTotalSec = (_focusMinutes * 60) + _focusSeconds;
    final breakTotalSec = (_breakMinutes * 60) + _breakSeconds;

    if (focusTotalSec <= 0 && breakTotalSec <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a focus or break duration greater than 0.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
            minController: _focusMinController,
            secController: _focusSecController,
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
            minController: _breakMinController,
            secController: _breakSecController,
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
                          '$_iterations ${_iterations == 1 ? "round" : "rounds"}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          'Cycles',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _iterations.toDouble().clamp(1.0, 50.0),
                          min: 1,
                          max: 50,
                          divisions: 49,
                          activeColor: theme.colorScheme.tertiary,
                          label: '$_iterations',
                          onChanged: (val) {
                            final count = val.round();
                            if (count == _iterations) return;
                            setState(() {
                              _iterations = count;
                              if (_iterationsController.text != '$count') {
                                _iterationsController.text = '$count';
                              }
                            });
                          },
                        ),
                      ),
                      EditableValueField(
                        controller: _iterationsController,
                        value: _iterations,
                        min: 1,
                        max: 50,
                        suffix: 'x',
                        accentColor: theme.colorScheme.tertiary,
                        onChanged: (newCount) {
                          setState(() {
                            _iterations = newCount;
                          });
                        },
                      ),
                    ],
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
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryMagenta.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _startQuickSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
              label: Text(
                'Start Session',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
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
    required TextEditingController minController,
    required TextEditingController secController,
    required void Function(int min, int sec) onChanged,
  }) {
    final theme = Theme.of(context);

    String durationText;
    if (minutes == 0 && seconds == 0) {
      durationText = '0 min';
    } else if (minutes == 0) {
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
            // Minutes Slider & Editable Field
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'Minutes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: minutes.toDouble().clamp(0.0, 90.0),
                    min: 0,
                    max: 90,
                    divisions: 90,
                    activeColor: accentColor,
                    label: '$minutes m',
                    onChanged: (val) {
                      final newMin = val.round();
                      final newSec = (newMin == 0 && seconds == 0) ? 15 : seconds;
                      if (newMin == minutes && newSec == seconds) return;
                      if (minController.text != '$newMin') {
                        minController.text = '$newMin';
                      }
                      if (newSec != seconds && secController.text != '$newSec') {
                        secController.text = '$newSec';
                      }
                      onChanged(newMin, newSec);
                    },
                  ),
                ),
                EditableValueField(
                  controller: minController,
                  value: minutes,
                  min: 0,
                  max: 90,
                  suffix: 'm',
                  accentColor: accentColor,
                  onChanged: (newMin) {
                    final newSec = (newMin == 0 && seconds == 0) ? 15 : seconds;
                    if (newSec != seconds && secController.text != '$newSec') {
                      secController.text = '$newSec';
                    }
                    onChanged(newMin, newSec);
                  },
                ),
              ],
            ),
            // Seconds Slider & Editable Field
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'Seconds',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: seconds.toDouble().clamp(0.0, 59.0),
                    min: 0,
                    max: 59,
                    divisions: 59,
                    activeColor: accentColor,
                    label: '$seconds s',
                    onChanged: (val) {
                      final newSec = val.round();
                      final newMin = (minutes == 0 && newSec == 0) ? 1 : minutes;
                      if (newSec == seconds && newMin == minutes) return;
                      if (secController.text != '$newSec') {
                        secController.text = '$newSec';
                      }
                      if (newMin != minutes && minController.text != '$newMin') {
                        minController.text = '$newMin';
                      }
                      onChanged(newMin, newSec);
                    },
                  ),
                ),
                EditableValueField(
                  controller: secController,
                  value: seconds,
                  min: 0,
                  max: 59,
                  suffix: 's',
                  accentColor: accentColor,
                  onChanged: (newSec) {
                    final newMin = (minutes == 0 && newSec == 0) ? 1 : minutes;
                    if (newMin != minutes && minController.text != '$newMin') {
                      minController.text = '$newMin';
                    }
                    onChanged(newMin, newSec);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditableValueField extends StatefulWidget {
  final TextEditingController controller;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final Color accentColor;
  final ValueChanged<int> onChanged;

  const EditableValueField({
    super.key,
    required this.controller,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  State<EditableValueField> createState() => _EditableValueFieldState();
}

class _EditableValueFieldState extends State<EditableValueField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant EditableValueField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.controller.text != '${widget.value}') {
      widget.controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _finalizeValue();
    }
  }

  void _finalizeValue() {
    final parsed = int.tryParse(widget.controller.text);
    final finalVal = (parsed ?? widget.value).clamp(widget.min, widget.max);
    if (widget.controller.text != '$finalVal') {
      widget.controller.text = '$finalVal';
    }
    widget.onChanged(finalVal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 62,
      height: 38,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(widget.max >= 100 ? 3 : 2),
        ],
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          suffixText: widget.suffix,
          suffixStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: widget.accentColor,
              width: 1.8,
            ),
          ),
          isDense: true,
        ),
        onChanged: (text) {
          if (text.isEmpty) return;
          final val = int.tryParse(text);
          if (val != null) {
            final clamped = val.clamp(widget.min, widget.max);
            widget.onChanged(clamped);
          }
        },
        onSubmitted: (_) {
          _finalizeValue();
          FocusScope.of(context).unfocus();
        },
        onTapOutside: (_) {
          _finalizeValue();
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}

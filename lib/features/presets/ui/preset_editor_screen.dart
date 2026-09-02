import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:pace_amigo/features/presets/models/routine_preset.dart';
import 'package:pace_amigo/features/timer/models/interval_phase.dart';
import 'package:pace_amigo/features/presets/providers/preset_provider.dart';

class PresetEditorScreen extends ConsumerStatefulWidget {
  final RoutinePreset? presetToEdit;

  const PresetEditorScreen({super.key, this.presetToEdit});

  @override
  ConsumerState<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends ConsumerState<PresetEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late int _iterations;
  late List<IntervalPhase> _phases;

  @override
  void initState() {
    super.initState();
    final existing = widget.presetToEdit;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    _iterations = existing?.iterations ?? 3;

    if (existing != null) {
      _phases = List<IntervalPhase>.from(existing.phases);
    } else {
      _phases = [
        const IntervalPhase(
          id: 'initial_focus',
          type: IntervalPhaseType.focus,
          name: 'Focus',
          durationInSeconds: 25 * 60,
        ),
        const IntervalPhase(
          id: 'initial_break',
          type: IntervalPhaseType.shortBreak,
          name: 'Break',
          durationInSeconds: 5 * 60,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addPhase() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PhaseConfigModal(
        onPhaseCreated: (newPhase) {
          setState(() {
            _phases.add(newPhase);
          });
        },
      ),
    );
  }

  void _editPhase(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PhaseConfigModal(
        initialPhase: _phases[index],
        onPhaseCreated: (updated) {
          setState(() {
            _phases[index] = updated;
          });
        },
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a routine name')),
      );
      return;
    }
    if (_phases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one interval phase')),
      );
      return;
    }

    final preset = RoutinePreset(
      id: widget.presetToEdit?.id ?? const Uuid().v4(),
      name: name,
      description: _descriptionController.text.trim(),
      iterations: _iterations,
      phases: _phases,
      isCustomSequence: true,
      createdAt: widget.presetToEdit?.createdAt ?? DateTime.now(),
    );

    ref.read(presetsProvider.notifier).savePreset(preset);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.presetToEdit == null ? 'Create Routine' : 'Edit Routine',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Routine Name & Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Routine Name',
                        hintText: 'e.g., Deep Sprint, HIIT Tabata, Writing Block',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Notes or purpose for this routine...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Iterations card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Repeat Routine',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$_iterations cycles',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _iterations.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 11,
                      onChanged: (val) =>
                          setState(() => _iterations = val.round()),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Phases header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Interval Sequence',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addPhase,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Step'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Drag handles to reorder the sequence.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Reorderable list of phases
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _phases.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _phases.removeAt(oldIndex);
                  _phases.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final phase = _phases[index];
                final min = phase.durationInSeconds ~/ 60;
                final sec = phase.durationInSeconds % 60;
                final timeLabel =
                    sec > 0 ? '$min m $sec s' : '$min min';

                Color badgeColor = theme.colorScheme.primary;
                IconData badgeIcon = Icons.flash_on_rounded;
                if (phase.type == IntervalPhaseType.shortBreak ||
                    phase.type == IntervalPhaseType.longBreak) {
                  badgeColor = theme.colorScheme.secondary;
                  badgeIcon = Icons.spa_rounded;
                } else if (phase.type == IntervalPhaseType.custom) {
                  badgeColor = theme.colorScheme.tertiary;
                  badgeIcon = Icons.tune_rounded;
                }

                return Card(
                  key: ValueKey(phase.id + index.toString()),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: badgeColor.withValues(alpha: 0.15),
                      child: Icon(badgeIcon, color: badgeColor, size: 20),
                    ),
                    title: Text(
                      phase.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Duration: $timeLabel',
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _editPhase(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 20),
                          onPressed: () {
                            if (_phases.length > 1) {
                              setState(() => _phases.removeAt(index));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('At least 1 phase is required'),
                                ),
                              );
                            }
                          },
                        ),
                        const Icon(Icons.drag_indicator_rounded,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseConfigModal extends StatefulWidget {
  final IntervalPhase? initialPhase;
  final void Function(IntervalPhase) onPhaseCreated;

  const _PhaseConfigModal({
    this.initialPhase,
    required this.onPhaseCreated,
  });

  @override
  State<_PhaseConfigModal> createState() => _PhaseConfigModalState();
}

class _PhaseConfigModalState extends State<_PhaseConfigModal> {
  late final TextEditingController _nameCtrl;
  late IntervalPhaseType _selectedType;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPhase;
    _nameCtrl = TextEditingController(text: p?.name ?? 'Focus');
    _selectedType = p?.type ?? IntervalPhaseType.focus;
    _minutes = p != null ? p.durationInSeconds ~/ 60 : 25;
    _seconds = p != null ? p.durationInSeconds % 60 : 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialPhase == null ? 'Add Interval Phase' : 'Edit Interval Phase',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Phase Label',
              hintText: 'e.g. Deep Sprint, Rest, Warmup, Stretch',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: IntervalPhaseType.values.map((type) {
              final isSel = type == _selectedType;
              return ChoiceChip(
                label: Text(type.name.toUpperCase()),
                selected: isSel,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _selectedType = type;
                      if (_nameCtrl.text.isEmpty ||
                          _nameCtrl.text == 'Focus' ||
                          _nameCtrl.text == 'Break') {
                        _nameCtrl.text = type == IntervalPhaseType.focus
                            ? 'Focus'
                            : type == IntervalPhaseType.shortBreak
                                ? 'Break'
                                : 'Custom Interval';
                      }
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Duration: $_minutes min $_seconds sec',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Minutes', style: GoogleFonts.inter(fontSize: 12)),
                    Slider(
                      value: _minutes.toDouble(),
                      min: 0,
                      max: 90,
                      divisions: 90,
                      onChanged: (v) => setState(() => _minutes = v.round()),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seconds', style: GoogleFonts.inter(fontSize: 12)),
                    Slider(
                      value: _seconds.toDouble(),
                      min: 0,
                      max: 55,
                      divisions: 11,
                      onChanged: (v) => setState(() => _seconds = v.round()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                final totalSec = (_minutes * 60) + _seconds;
                if (totalSec <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Duration must be greater than 0'),
                    ),
                  );
                  return;
                }

                final phase = IntervalPhase(
                  id: widget.initialPhase?.id ?? const Uuid().v4(),
                  type: _selectedType,
                  name: _nameCtrl.text.trim().isEmpty
                      ? 'Interval'
                      : _nameCtrl.text.trim(),
                  durationInSeconds: totalSec,
                );

                widget.onPhaseCreated(phase);
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

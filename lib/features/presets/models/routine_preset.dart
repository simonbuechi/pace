import 'package:flutter/material.dart';
import '../../timer/models/interval_phase.dart';

class RoutinePreset {
  final String id;
  final String name;
  final String description;
  final int iterations; // How many times the sequence repeats
  final List<IntervalPhase> phases; // The sequence of phases per iteration
  final int? focusColorValue;
  final int? breakColorValue;
  final bool isCustomSequence;
  final DateTime createdAt;

  const RoutinePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.iterations,
    required this.phases,
    this.focusColorValue,
    this.breakColorValue,
    this.isCustomSequence = false,
    required this.createdAt,
  });

  Color? get focusColor =>
      focusColorValue != null ? Color(focusColorValue!) : null;
  Color? get breakColor =>
      breakColorValue != null ? Color(breakColorValue!) : null;

  int get totalDurationSeconds {
    final iterationSum = phases.fold<int>(
      0,
      (sum, p) => sum + p.durationInSeconds,
    );
    return iterationSum * iterations;
  }

  String get formattedTotalDuration {
    final totalSec = totalDurationSeconds;
    final minutes = totalSec ~/ 60;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMin = minutes % 60;
    return '${hours}h ${remainingMin}m';
  }

  RoutinePreset copyWith({
    String? id,
    String? name,
    String? description,
    int? iterations,
    List<IntervalPhase>? phases,
    int? focusColorValue,
    int? breakColorValue,
    bool? isCustomSequence,
    DateTime? createdAt,
  }) {
    return RoutinePreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iterations: iterations ?? this.iterations,
      phases: phases ?? this.phases,
      focusColorValue: focusColorValue ?? this.focusColorValue,
      breakColorValue: breakColorValue ?? this.breakColorValue,
      isCustomSequence: isCustomSequence ?? this.isCustomSequence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iterations': iterations,
    'phases': phases.map((p) => p.toJson()).toList(),
    'focusColorValue': focusColorValue,
    'breakColorValue': breakColorValue,
    'isCustomSequence': isCustomSequence,
    'createdAt': createdAt.toIso8601String(),
  };

  factory RoutinePreset.fromJson(Map<String, dynamic> json) {
    return RoutinePreset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iterations: json['iterations'] as int? ?? 1,
      phases: (json['phases'] as List<dynamic>?)
              ?.map((p) => IntervalPhase.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      focusColorValue: json['focusColorValue'] as int?,
      breakColorValue: json['breakColorValue'] as int?,
      isCustomSequence: json['isCustomSequence'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Factory for standard quick start or Pomodoro cycle
  factory RoutinePreset.createStandard({
    required String id,
    required String name,
    required String description,
    required int focusMinutes,
    int focusSeconds = 0,
    required int breakMinutes,
    int breakSeconds = 0,
    required int iterations,
    int? longBreakMinutes,
    int? longBreakInterval,
    int? focusColorValue,
    int? breakColorValue,
  }) {
    final focusTotalSec = (focusMinutes * 60) + focusSeconds;
    final breakTotalSec = (breakMinutes * 60) + breakSeconds;

    final phases = <IntervalPhase>[
      IntervalPhase(
        id: 'phase_focus',
        type: IntervalPhaseType.focus,
        name: 'Focus',
        durationInSeconds: focusTotalSec,
      ),
      IntervalPhase(
        id: 'phase_break',
        type: IntervalPhaseType.shortBreak,
        name: 'Break',
        durationInSeconds: breakTotalSec,
      ),
    ];

    return RoutinePreset(
      id: id,
      name: name,
      description: description,
      iterations: iterations,
      phases: phases,
      focusColorValue: focusColorValue,
      breakColorValue: breakColorValue,
      isCustomSequence: false,
      createdAt: DateTime.now(),
    );
  }
}

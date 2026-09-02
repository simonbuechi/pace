import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine_preset.dart';
import '../../timer/models/interval_phase.dart';
import 'preset_repository.dart';

class HivePresetRepository implements PresetRepository {
  static const String _boxName = 'pace_presets_box';
  Box<String>? _box;
  final Map<String, RoutinePreset> _memoryCache = {};

  @override
  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<String>(_boxName);
      } else {
        _box = Hive.box<String>(_boxName);
      }

      // Populate default presets if empty
      if (_box!.isEmpty) {
        for (final preset in _defaultPresets) {
          await savePreset(preset);
        }
      }
    } catch (e) {
      debugPrint('HivePresetRepository init warning (fallback to in-memory): $e');
      if (_memoryCache.isEmpty) {
        for (final preset in _defaultPresets) {
          _memoryCache[preset.id] = preset;
        }
      }
    }
  }

  @override
  Future<List<RoutinePreset>> getPresets() async {
    if (_box != null && _box!.isOpen) {
      final list = <RoutinePreset>[];
      for (final key in _box!.keys) {
        final raw = _box!.get(key);
        if (raw != null) {
          try {
            final map = jsonDecode(raw) as Map<String, dynamic>;
            list.add(RoutinePreset.fromJson(map));
          } catch (e) {
            debugPrint('Error parsing preset $key: $e');
          }
        }
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } else {
      final list = _memoryCache.values.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  @override
  Future<RoutinePreset?> getPresetById(String id) async {
    if (_box != null && _box!.isOpen) {
      final raw = _box!.get(id);
      if (raw == null) return null;
      return RoutinePreset.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } else {
      return _memoryCache[id];
    }
  }

  @override
  Future<void> savePreset(RoutinePreset preset) async {
    _memoryCache[preset.id] = preset;
    if (_box != null && _box!.isOpen) {
      final jsonStr = jsonEncode(preset.toJson());
      await _box!.put(preset.id, jsonStr);
    }
  }

  @override
  Future<void> deletePreset(String id) async {
    _memoryCache.remove(id);
    if (_box != null && _box!.isOpen) {
      await _box!.delete(id);
    }
  }

  static final List<RoutinePreset> _defaultPresets = [
    RoutinePreset.createStandard(
      id: 'default_pomodoro',
      name: 'Classic Pomodoro',
      description: '25 min focus followed by 5 min restful recovery.',
      focusMinutes: 25,
      breakMinutes: 5,
      iterations: 4,
    ),
    RoutinePreset.createStandard(
      id: 'default_ultradian',
      name: 'Ultradian Deep Work',
      description: '90 min deep cognitive session with 20 min decompression.',
      focusMinutes: 90,
      breakMinutes: 20,
      iterations: 2,
    ),
    RoutinePreset(
      id: 'default_tabata',
      name: 'Tabata High Intensity',
      description: '8 rounds: 10s warmup, 20s maximum exertion, 10s recovery.',
      iterations: 8,
      isCustomSequence: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      phases: const [
        IntervalPhase(
          id: 'tabata_prep',
          type: IntervalPhaseType.custom,
          name: 'Warmup / Prep',
          durationInSeconds: 10,
          colorValue: 0xFFF4A261,
        ),
        IntervalPhase(
          id: 'tabata_sprint',
          type: IntervalPhaseType.focus,
          name: 'Sprint / Push',
          durationInSeconds: 20,
          colorValue: 0xFFE63946,
        ),
        IntervalPhase(
          id: 'tabata_rest',
          type: IntervalPhaseType.shortBreak,
          name: 'Rest',
          durationInSeconds: 10,
          colorValue: 0xFF2A9D8F,
        ),
      ],
    ),
    RoutinePreset.createStandard(
      id: 'default_quick_stretch',
      name: 'Desk Reset & Stretch',
      description: 'Short 7-minute posture recharge and eye relaxation.',
      focusMinutes: 7,
      breakMinutes: 2,
      iterations: 3,
    ),
  ];
}

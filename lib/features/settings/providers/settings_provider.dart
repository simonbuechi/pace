import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pace_amigo/core/constants/app_colors.dart';
import 'package:pace_amigo/core/providers/core_providers.dart';
import 'package:pace_amigo/features/settings/models/user_settings.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  static const String _boxName = 'pace_settings_box';
  final Ref _ref;
  Box<String>? _box;

  SettingsNotifier(this._ref) : super(const UserSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<String>(_boxName);
      } else {
        _box = Hive.box<String>(_boxName);
      }

      final raw = _box?.get('current_settings');
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        state = UserSettings.fromJson(map);
      }
    } catch (e) {
      debugPrint('SettingsNotifier load warning: $e');
    }

    _applyToServices();
  }

  void _applyToServices() {
    final audio = _ref.read(audioServiceProvider);
    audio.isSoundEnabled = state.soundEnabled;

    final notif = _ref.read(notificationServiceProvider);
    notif.isEnabled = state.notificationsEnabled;
  }

  Future<void> _persist() async {
    _applyToServices();
    if (_box != null && _box!.isOpen) {
      final jsonStr = jsonEncode(state.toJson());
      await _box!.put('current_settings', jsonStr);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }

  Future<void> setFocusSound(String soundId) async {
    state = state.copyWith(focusSoundId: soundId);
    await _persist();
  }

  Future<void> setBreakSound(String soundId) async {
    state = state.copyWith(breakSoundId: soundId);
    await _persist();
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _persist();
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _persist();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier(ref);
});

final activeFocusColorProvider = Provider<Color>((ref) {
  return AppColors.focus;
});

final activeBreakColorProvider = Provider<Color>((ref) {
  return AppColors.rest;
});

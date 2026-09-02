import 'package:flutter/material.dart';

class UserSettings {
  final ThemeMode themeMode;
  final String selectedPaletteId;
  final int? customFocusColorValue;
  final int? customBreakColorValue;
  final String focusSoundId;
  final String breakSoundId;
  final bool soundEnabled;
  final bool notificationsEnabled;

  const UserSettings({
    this.themeMode = ThemeMode.system,
    this.selectedPaletteId = 'sunset_ember',
    this.customFocusColorValue,
    this.customBreakColorValue,
    this.focusSoundId = 'beep',
    this.breakSoundId = 'temple_bell',
    this.soundEnabled = true,
    this.notificationsEnabled = true,
  });

  UserSettings copyWith({
    ThemeMode? themeMode,
    String? selectedPaletteId,
    int? customFocusColorValue,
    int? customBreakColorValue,
    String? focusSoundId,
    String? breakSoundId,
    bool? soundEnabled,
    bool? notificationsEnabled,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      selectedPaletteId: selectedPaletteId ?? this.selectedPaletteId,
      customFocusColorValue:
          customFocusColorValue ?? this.customFocusColorValue,
      customBreakColorValue:
          customBreakColorValue ?? this.customBreakColorValue,
      focusSoundId: focusSoundId ?? this.focusSoundId,
      breakSoundId: breakSoundId ?? this.breakSoundId,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'selectedPaletteId': selectedPaletteId,
    'customFocusColorValue': customFocusColorValue,
    'customBreakColorValue': customBreakColorValue,
    'focusSoundId': focusSoundId,
    'breakSoundId': breakSoundId,
    'soundEnabled': soundEnabled,
    'notificationsEnabled': notificationsEnabled,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      selectedPaletteId:
          json['selectedPaletteId'] as String? ?? 'sunset_ember',
      customFocusColorValue: json['customFocusColorValue'] as int?,
      customBreakColorValue: json['customBreakColorValue'] as int?,
      focusSoundId: json['focusSoundId'] as String? ?? 'beep',
      breakSoundId: json['breakSoundId'] as String? ?? 'temple_bell',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }
}

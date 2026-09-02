import 'dart:convert';

/// Represents a successfully completed focus session.
class FocusRunLog {
  final String id;
  final String presetId;
  final String presetName;
  final int focusDurationSeconds;
  final int totalDurationSeconds;
  final int iterations;
  final DateTime completedAt;
  final bool isSynced;

  const FocusRunLog({
    required this.id,
    required this.presetId,
    required this.presetName,
    required this.focusDurationSeconds,
    required this.totalDurationSeconds,
    required this.iterations,
    required this.completedAt,
    this.isSynced = false,
  });

  FocusRunLog copyWith({
    String? id,
    String? presetId,
    String? presetName,
    int? focusDurationSeconds,
    int? totalDurationSeconds,
    int? iterations,
    DateTime? completedAt,
    bool? isSynced,
  }) {
    return FocusRunLog(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      presetName: presetName ?? this.presetName,
      focusDurationSeconds: focusDurationSeconds ?? this.focusDurationSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      iterations: iterations ?? this.iterations,
      completedAt: completedAt ?? this.completedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  String get formattedDuration {
    final m = focusDurationSeconds ~/ 60;
    final s = focusDurationSeconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}m';
    return '${m}m ${s}s';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'presetId': presetId,
        'presetName': presetName,
        'focusDurationSeconds': focusDurationSeconds,
        'totalDurationSeconds': totalDurationSeconds,
        'iterations': iterations,
        'completedAt': completedAt.toIso8601String(),
        'isSynced': isSynced,
      };

  factory FocusRunLog.fromMap(Map<String, dynamic> map) {
    return FocusRunLog(
      id: map['id'] as String,
      presetId: map['presetId'] as String? ?? 'quick_start',
      presetName: map['presetName'] as String? ?? 'Focus Session',
      focusDurationSeconds: (map['focusDurationSeconds'] as num?)?.toInt() ?? 0,
      totalDurationSeconds: (map['totalDurationSeconds'] as num?)?.toInt() ?? 0,
      iterations: (map['iterations'] as num?)?.toInt() ?? 1,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isSynced: (map['isSynced'] as bool?) ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FocusRunLog.fromJson(String source) =>
      FocusRunLog.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

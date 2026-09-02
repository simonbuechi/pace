enum IntervalPhaseType { focus, shortBreak, longBreak, custom }

class IntervalPhase {
  final String id;
  final IntervalPhaseType type;
  final String name;
  final int durationInSeconds;
  final int? colorValue;
  final String? soundId;

  const IntervalPhase({
    required this.id,
    required this.type,
    required this.name,
    required this.durationInSeconds,
    this.colorValue,
    this.soundId,
  });

  bool get isFocus => type == IntervalPhaseType.focus;
  bool get isBreak =>
      type == IntervalPhaseType.shortBreak ||
      type == IntervalPhaseType.longBreak;

  IntervalPhase copyWith({
    String? id,
    IntervalPhaseType? type,
    String? name,
    int? durationInSeconds,
    int? colorValue,
    String? soundId,
  }) {
    return IntervalPhase(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      colorValue: colorValue ?? this.colorValue,
      soundId: soundId ?? this.soundId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'durationInSeconds': durationInSeconds,
    'colorValue': colorValue,
    'soundId': soundId,
  };

  factory IntervalPhase.fromJson(Map<String, dynamic> json) {
    return IntervalPhase(
      id: json['id'] as String,
      type: IntervalPhaseType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => IntervalPhaseType.focus,
      ),
      name: json['name'] as String,
      durationInSeconds: json['durationInSeconds'] as int,
      colorValue: json['colorValue'] as int?,
      soundId: json['soundId'] as String?,
    );
  }
}

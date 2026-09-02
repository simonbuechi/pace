class SoundOption {
  final String id;
  final String name;
  final String assetPath;
  final String description;

  const SoundOption({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.description,
  });
}

class AppSounds {
  static const SoundOption standardBeep = SoundOption(
    id: 'beep',
    name: 'Standard Beep',
    assetPath: 'sounds/beep.wav',
    description: 'Crisp, bright dual-frequency prompt',
  );

  static const SoundOption templeBell = SoundOption(
    id: 'temple_bell',
    name: 'Temple Bell',
    assetPath: 'sounds/temple_bell.wav',
    description: 'Resonant harmonic bell with soothing decay',
  );

  static const SoundOption digitalPulse = SoundOption(
    id: 'digital_pulse',
    name: 'Digital Pulse',
    assetPath: 'sounds/digital_pulse.wav',
    description: 'Modern high-tech ascending tri-pulse',
  );

  static const List<SoundOption> all = [
    standardBeep,
    templeBell,
    digitalPulse,
  ];

  static SoundOption findById(String id) {
    return all.firstWhere(
      (s) => s.id == id,
      orElse: () => standardBeep,
    );
  }
}

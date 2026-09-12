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

  static const SoundOption singingBowl = SoundOption(
    id: 'singing_bowl',
    name: 'Tibetan Singing Bowl',
    assetPath: 'sounds/singing_bowl.wav',
    description: 'Warm 432Hz meditative resonance with lush harmonics',
  );

  static const SoundOption gentleChime = SoundOption(
    id: 'gentle_chime',
    name: 'Gentle Chime',
    assetPath: 'sounds/gentle_chime.wav',
    description: 'Airy, sparkling harmonic wind chimes',
  );

  static const SoundOption marimbaPop = SoundOption(
    id: 'marimba_pop',
    name: 'Soft Marimba',
    assetPath: 'sounds/marimba_pop.wav',
    description: 'Warm organic wooden acoustic mallet strike',
  );

  static const SoundOption zenGong = SoundOption(
    id: 'zen_gong',
    name: 'Zen Gong',
    assetPath: 'sounds/zen_gong.wav',
    description: 'Deep grounding reverberation with slow decay',
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
    singingBowl,
    gentleChime,
    marimbaPop,
    zenGong,
    digitalPulse,
  ];

  static SoundOption findById(String id) {
    return all.firstWhere(
      (s) => s.id == id,
      orElse: () => standardBeep,
    );
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_sounds.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool isSoundEnabled = true;
  double volume = 0.85;

  AudioService() {
    _init();
  }

  void _init() {
    try {
      _player.setVolume(volume);
      _player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('AudioService init warning: $e');
    }
  }

  Future<void> playSound(SoundOption sound) async {
    if (!isSoundEnabled) return;
    try {
      await _player.stop();
      await _player.setVolume(volume);
      await _player.play(AssetSource(sound.assetPath));
    } catch (e) {
      debugPrint('Error playing sound ${sound.id}: $e');
    }
  }

  Future<void> playFocusStartSound(String soundId) async {
    final sound = AppSounds.findById(soundId);
    await playSound(sound);
  }

  Future<void> playBreakStartSound(String soundId) async {
    final sound = AppSounds.findById(soundId);
    await playSound(sound);
  }

  void dispose() {
    _player.dispose();
  }
}

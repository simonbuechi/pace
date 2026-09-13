import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_sounds.dart';

class AudioService {
  AudioPlayer? _player;
  bool isSoundEnabled = true;
  double volume = 0.85;

  AudioPlayer _getPlayer() {
    if (_player == null) {
      _player = AudioPlayer();
      try {
        _player!.setVolume(volume);
        _player!.setReleaseMode(ReleaseMode.stop);
      } catch (e) {
        debugPrint('AudioService init warning: $e');
      }
    }
    return _player!;
  }

  Future<void> playSound(SoundOption sound) async {
    if (!isSoundEnabled) return;
    try {
      final player = _getPlayer();
      await player.stop();
      await player.setVolume(volume);
      await player.play(AssetSource(sound.assetPath));
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
    _player?.dispose();
  }
}

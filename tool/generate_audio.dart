import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

Uint8List createWav(List<double> samples, {int sampleRate = 44100}) {
  final byteLength = samples.length * 2;
  final buffer = ByteData(44 + byteLength);

  // RIFF header
  buffer.setUint8(0, 0x52); // R
  buffer.setUint8(1, 0x49); // I
  buffer.setUint8(2, 0x46); // F
  buffer.setUint8(3, 0x46); // F
  buffer.setUint32(4, 36 + byteLength, Endian.little);
  buffer.setUint8(8, 0x57); // W
  buffer.setUint8(9, 0x41); // A
  buffer.setUint8(10, 0x56); // V
  buffer.setUint8(11, 0x45); // E

  // fmt subchunk
  buffer.setUint8(12, 0x66); // f
  buffer.setUint8(13, 0x6D); // m
  buffer.setUint8(14, 0x74); // t
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // subchunk size
  buffer.setUint16(20, 1, Endian.little); // PCM
  buffer.setUint16(22, 1, Endian.little); // 1 channel (mono)
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little); // Byte rate
  buffer.setUint16(32, 2, Endian.little); // Block align
  buffer.setUint16(34, 16, Endian.little); // Bits per sample

  // data subchunk
  buffer.setUint8(36, 0x64); // d
  buffer.setUint8(37, 0x61); // a
  buffer.setUint8(38, 0x74); // t
  buffer.setUint8(39, 0x61); // a
  buffer.setUint32(40, byteLength, Endian.little);

  for (int i = 0; i < samples.length; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    final intSample = (clamped * 32767.0).round();
    buffer.setInt16(44 + i * 2, intSample, Endian.little);
  }

  return buffer.buffer.asUint8List();
}

List<double> generateStandardBeep({int sampleRate = 44100}) {
  // Dual tone beep: 880Hz then 1318Hz with smooth envelope
  final totalDuration = 0.55;
  final totalSamples = (sampleRate * totalDuration).toInt();
  final samples = List<double>.filled(totalSamples, 0.0);

  final tone1Samples = (sampleRate * 0.18).toInt();
  final pauseSamples = (sampleRate * 0.06).toInt();
  final tone2Samples = (sampleRate * 0.25).toInt();

  for (int i = 0; i < tone1Samples; i++) {
    final t = i / sampleRate;
    final env = sin(pi * i / tone1Samples);
    samples[i] = sin(2 * pi * 880 * t) * env * 0.7;
  }

  final offset = tone1Samples + pauseSamples;
  for (int i = 0; i < tone2Samples; i++) {
    final t = i / sampleRate;
    final env = sin(pi * i / tone2Samples);
    samples[offset + i] = sin(2 * pi * 1318.5 * t) * env * 0.8;
  }

  return samples;
}

List<double> generateTempleBell({int sampleRate = 44100}) {
  // Rich bell tone: 528Hz fundamental with harmonics and exponential decay
  final totalDuration = 1.8;
  final totalSamples = (sampleRate * totalDuration).toInt();
  final samples = List<double>.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final attack = (i < 500) ? i / 500.0 : 1.0;
    final decay = exp(-2.2 * t);
    final wave1 = sin(2 * pi * 528 * t);
    final wave2 = sin(2 * pi * 1056 * t) * 0.35;
    final wave3 = sin(2 * pi * 1584 * t) * 0.15;
    final wave4 = sin(2 * pi * 792 * t) * 0.2;
    samples[i] = (wave1 + wave2 + wave3 + wave4) * attack * decay * 0.7;
  }

  return samples;
}

List<double> generateDigitalPulse({int sampleRate = 44100}) {
  // Modern techno pulse: 3 fast rising chirps
  final totalDuration = 0.5;
  final totalSamples = (sampleRate * totalDuration).toInt();
  final samples = List<double>.filled(totalSamples, 0.0);

  final pulses = 3;
  final pulseLength = (totalSamples / pulses).toInt();

  for (int p = 0; p < pulses; p++) {
    final startIdx = p * pulseLength;
    final activeLen = (pulseLength * 0.7).toInt();
    for (int i = 0; i < activeLen; i++) {
      final t = i / sampleRate;
      final env = sin(pi * i / activeLen);
      final freq = 700.0 + (p * 200.0);
      samples[startIdx + i] = sin(2 * pi * freq * t) * env * 0.75;
    }
  }

  return samples;
}

void main() {
  final outDir = Directory('assets/sounds');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  File('assets/sounds/beep.wav').writeAsBytesSync(createWav(generateStandardBeep()));
  print('Generated beep.wav');

  File('assets/sounds/temple_bell.wav').writeAsBytesSync(createWav(generateTempleBell()));
  print('Generated temple_bell.wav');

  File('assets/sounds/digital_pulse.wav').writeAsBytesSync(createWav(generateDigitalPulse()));
  print('Generated digital_pulse.wav');
}

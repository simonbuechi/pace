import 'package:flutter/material.dart';

/// Centralized color palette for Pace Amigo.
/// Uses the signature primary gradient colors exclusively throughout the app.
class AppColors {
  // Primary Signature Colors
  static const Color primaryPurple = Color(0xFF9025A7); // Deep Amethyst Focus
  static const Color primaryMagenta = Color(0xFFD81860); // Electric Magenta Rest

  // Interval Phase Bindings
  static const Color focus = primaryPurple;
  static const Color rest = primaryMagenta;

  // Signature Primary Gradient (#9025A7 -> #D81860)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surface & Neutral tones
  static const Color lightScaffold = Color(0xFFF8F9FD);
  static const Color darkScaffold = Color(0xFF100E17);
  static const Color darkCard = Color(0xFF1C1826);
}

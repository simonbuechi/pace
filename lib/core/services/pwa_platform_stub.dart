import 'package:flutter/foundation.dart';

abstract class PwaServicePlatform {
  bool get isStandalone;
  bool get isPromptAvailable;
  Future<bool> promptInstall();
  void registerListeners({
    required VoidCallback onPromptAvailable,
    required VoidCallback onInstalled,
  });
}

class PwaServiceStub implements PwaServicePlatform {
  @override
  bool get isStandalone => false;

  @override
  bool get isPromptAvailable => false;

  @override
  Future<bool> promptInstall() async => false;

  @override
  void registerListeners({
    required VoidCallback onPromptAvailable,
    required VoidCallback onInstalled,
  }) {}
}

PwaServicePlatform getPwaPlatform() => PwaServiceStub();

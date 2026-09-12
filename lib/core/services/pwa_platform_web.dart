import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'pwa_platform_stub.dart';
export 'pwa_platform_stub.dart';

@JS('pwaInstall.isInstalled')
external bool? get _jsIsInstalled;

@JS('pwaInstall.isPromptAvailable')
external bool? get _jsIsPromptAvailable;

@JS('pwaInstall.promptInstall')
external JSPromise<JSBoolean>? _jsPromptInstall();

@JS('window.addEventListener')
external void _addEventListener(String type, JSFunction listener);

class PwaServiceWeb implements PwaServicePlatform {
  @override
  bool get isStandalone {
    try {
      return _jsIsInstalled ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  bool get isPromptAvailable {
    try {
      return _jsIsPromptAvailable ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> promptInstall() async {
    try {
      final promise = _jsPromptInstall();
      if (promise != null) {
        final result = await promise.toDart;
        return result.toDart;
      }
    } catch (e) {
      debugPrint('Error triggering PWA install: $e');
    }
    return false;
  }

  @override
  void registerListeners({
    required VoidCallback onPromptAvailable,
    required VoidCallback onInstalled,
  }) {
    try {
      _addEventListener(
        'pwa-install-available',
        (() => onPromptAvailable()).toJS,
      );
      _addEventListener(
        'pwa-installed',
        (() => onInstalled()).toJS,
      );
    } catch (e) {
      debugPrint('Error registering PWA listeners: $e');
    }
  }
}

PwaServicePlatform getPwaPlatform() => PwaServiceWeb();

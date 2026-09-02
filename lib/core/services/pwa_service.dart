import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pwa_platform_stub.dart'
    if (dart.library.html) 'pwa_platform_web.dart';

class PwaState {
  final bool isWeb;
  final bool isStandalone;
  final bool canPrompt;
  final bool isDismissed;

  const PwaState({
    this.isWeb = false,
    this.isStandalone = false,
    this.canPrompt = false,
    this.isDismissed = false,
  });

  bool get shouldShowInstallPrompt => isWeb && !isStandalone && !isDismissed;

  PwaState copyWith({
    bool? isWeb,
    bool? isStandalone,
    bool? canPrompt,
    bool? isDismissed,
  }) {
    return PwaState(
      isWeb: isWeb ?? this.isWeb,
      isStandalone: isStandalone ?? this.isStandalone,
      canPrompt: canPrompt ?? this.canPrompt,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

class PwaNotifier extends StateNotifier<PwaState> {
  final PwaServicePlatform _platform;

  PwaNotifier([PwaServicePlatform? platform])
      : _platform = platform ?? getPwaPlatform(),
        super(PwaState(
          isWeb: kIsWeb,
          isStandalone: platform != null
              ? platform.isStandalone
              : (kIsWeb ? getPwaPlatform().isStandalone : false),
          canPrompt: platform != null
              ? platform.isPromptAvailable
              : (kIsWeb ? getPwaPlatform().isPromptAvailable : false),
          isDismissed: false,
        )) {
    if (kIsWeb) {
      _platform.registerListeners(
        onPromptAvailable: () {
          state = state.copyWith(
            canPrompt: true,
            isStandalone: _platform.isStandalone,
          );
        },
        onInstalled: () {
          state = state.copyWith(
            isStandalone: true,
            canPrompt: false,
          );
        },
      );
    }
  }

  void dismissBanner() {
    state = state.copyWith(isDismissed: true);
  }

  Future<bool> promptInstall() async {
    final installed = await _platform.promptInstall();
    if (installed) {
      state = state.copyWith(isStandalone: true, canPrompt: false);
    }
    return installed;
  }
}

final pwaProvider = StateNotifierProvider<PwaNotifier, PwaState>((ref) {
  return PwaNotifier();
});

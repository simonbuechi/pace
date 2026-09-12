import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pace_amigo/core/services/pwa_platform_stub.dart';
import 'package:pace_amigo/core/services/pwa_service.dart';
import 'package:pace_amigo/features/home/widgets/pwa_install_banner.dart';

class MockPwaPlatform implements PwaServicePlatform {
  bool standalone;
  bool promptAvailable;
  bool promptResult;
  VoidCallback? onPrompt;
  VoidCallback? onInst;

  MockPwaPlatform({
    this.standalone = false,
    this.promptAvailable = true,
    this.promptResult = true,
  });

  @override
  bool get isStandalone => standalone;

  @override
  bool get isPromptAvailable => promptAvailable;

  @override
  Future<bool> promptInstall() async => promptResult;

  @override
  void registerListeners({
    required VoidCallback onPromptAvailable,
    required VoidCallback onInstalled,
  }) {
    onPrompt = onPromptAvailable;
    onInst = onInstalled;
  }
}

void main() {
  group('PWA State & Notifier Tests', () {
    test('PwaState calculates shouldShowInstallPrompt accurately', () {
      const webBrowserState = PwaState(
        isWeb: true,
        isStandalone: false,
        canPrompt: true,
        isDismissed: false,
      );
      expect(webBrowserState.shouldShowInstallPrompt, isTrue);

      const installedState = PwaState(
        isWeb: true,
        isStandalone: true,
        canPrompt: false,
        isDismissed: false,
      );
      expect(installedState.shouldShowInstallPrompt, isFalse);

      const dismissedState = PwaState(
        isWeb: true,
        isStandalone: false,
        canPrompt: true,
        isDismissed: true,
      );
      expect(dismissedState.shouldShowInstallPrompt, isFalse);

      const nonWebState = PwaState(
        isWeb: false,
        isStandalone: false,
        canPrompt: false,
        isDismissed: false,
      );
      expect(nonWebState.shouldShowInstallPrompt, isFalse);
    });

    test('PwaNotifier dismissBanner updates isDismissed', () {
      final mock = MockPwaPlatform();
      final notifier = PwaNotifier(mock);

      // Force web state for testing
      notifier.state = notifier.state.copyWith(isWeb: true, isDismissed: false);
      expect(notifier.state.shouldShowInstallPrompt, isTrue);

      notifier.dismissBanner();
      expect(notifier.state.isDismissed, isTrue);
      expect(notifier.state.shouldShowInstallPrompt, isFalse);
    });

    test('PwaNotifier promptInstall sets isStandalone on success', () async {
      final mock = MockPwaPlatform(promptResult: true);
      final notifier = PwaNotifier(mock);

      notifier.state = notifier.state.copyWith(isWeb: true, isStandalone: false);
      final result = await notifier.promptInstall();

      expect(result, isTrue);
      expect(notifier.state.isStandalone, isTrue);
      expect(notifier.state.shouldShowInstallPrompt, isFalse);
    });
  });

  group('PwaInstallBanner Widget Tests', () {
    testWidgets('Renders nothing when shouldShowInstallPrompt is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pwaProvider.overrideWith((ref) {
              final notifier = PwaNotifier(MockPwaPlatform(standalone: true));
              notifier.state = const PwaState(
                isWeb: true,
                isStandalone: true,
                canPrompt: false,
                isDismissed: false,
              );
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PwaInstallBanner(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Install Pace Amigo'), findsNothing);
    });

    testWidgets('Renders banner and dismisses upon tapping close button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pwaProvider.overrideWith((ref) {
              final notifier = PwaNotifier(MockPwaPlatform(standalone: false));
              notifier.state = const PwaState(
                isWeb: true,
                isStandalone: false,
                canPrompt: true,
                isDismissed: false,
              );
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PwaInstallBanner(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Banner should be visible
      expect(find.textContaining('Install Pace Amigo'), findsOneWidget);
      expect(find.text('Install'), findsOneWidget);

      // Tap Dismiss (close icon)
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      // Banner should now be dismissed
      expect(find.textContaining('Install Pace Amigo'), findsNothing);
    });

    testWidgets('SidebarInstallCard renders in extended and collapsed mode and dismisses',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pwaProvider.overrideWith((ref) {
              final notifier = PwaNotifier(MockPwaPlatform(standalone: false));
              notifier.state = const PwaState(
                isWeb: true,
                isStandalone: false,
                canPrompt: true,
                isDismissed: false,
              );
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SidebarInstallCard(isExtended: true),
            ),
          ),
        ),
      );

      await tester.pump();

      // Extended sidebar card should show title and action button
      expect(find.text('Install App'), findsOneWidget);
      expect(find.text('Install Now'), findsOneWidget);
      expect(find.text('Full-screen & offline mode'), findsOneWidget);

      // Dismiss card
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.text('Install App'), findsNothing);
    });

    testWidgets('SidebarInstallCard renders compact icon button when not extended',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pwaProvider.overrideWith((ref) {
              final notifier = PwaNotifier(MockPwaPlatform(standalone: false));
              notifier.state = const PwaState(
                isWeb: true,
                isStandalone: false,
                canPrompt: true,
                isDismissed: false,
              );
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SidebarInstallCard(isExtended: false),
            ),
          ),
        ),
      );

      await tester.pump();

      // Compact mode should show the install icon
      expect(find.byIcon(Icons.install_mobile_rounded), findsOneWidget);
      expect(find.text('Install App'), findsNothing);
    });
  });
}


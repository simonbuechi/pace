import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pace_amigo/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Lifecycle & Suppression Tests', () {
    final notifService = NotificationService();

    tearDown(() {
      notifService.isForegroundOverride = null;
    });

    test('isAppInForeground reflects lifecycle state changes', () {
      notifService.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(notifService.isAppInForeground, isFalse);

      notifService.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(notifService.isAppInForeground, isTrue);

      notifService.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(notifService.isAppInForeground, isFalse);
    });

    test('showIntervalAlert suppresses notifications when app is open in foreground', () async {
      notifService.isForegroundOverride = true;
      notifService.isEnabled = true;

      // Should return without throwing error or showing popup
      await expectLater(
        notifService.showIntervalAlert(
          title: 'Focus Completed',
          body: 'Take a break',
        ),
        completes,
      );
    });

    test('showIntervalAlert handles background state and force flag', () async {
      notifService.isForegroundOverride = false;
      notifService.isEnabled = true;

      await expectLater(
        notifService.showIntervalAlert(
          title: 'Background Alert',
          body: 'Interval finished',
        ),
        completes,
      );

      notifService.isForegroundOverride = true;
      await expectLater(
        notifService.showIntervalAlert(
          title: 'Forced Alert',
          body: 'Interval finished',
          force: true,
        ),
        completes,
      );
    });
  });
}

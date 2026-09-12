import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService with WidgetsBindingObserver {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool isEnabled = true;
  bool _isForeground = true;

  @visibleForTesting
  bool? isForegroundOverride;

  /// Returns true if the app is currently open and active on the display.
  bool get isAppInForeground {
    if (isForegroundOverride != null) return isForegroundOverride!;
    try {
      final state = WidgetsBinding.instance.lifecycleState;
      if (state != null) {
        return state == AppLifecycleState.resumed;
      }
    } catch (_) {}
    return _isForeground;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = (state == AppLifecycleState.resumed);
    debugPrint('NotificationService: lifecycle state -> $state (foreground: $_isForeground)');
  }

  Future<void> initialize() async {
    try {
      WidgetsBinding.instance.addObserver(this);
      final state = WidgetsBinding.instance.lifecycleState;
      if (state != null) {
        _isForeground = state == AppLifecycleState.resumed;
      }
    } catch (_) {}

    if (kIsWeb || _initialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init warning: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Request notification permissions warning: $e');
    }
  }

  Future<void> showIntervalAlert({
    required String title,
    required String body,
    bool force = false,
  }) async {
    if (kIsWeb || !isEnabled || !_initialized) return;

    // When the app is open and on the display (foreground), do not show push/system notifications
    if (!force && isAppInForeground) {
      debugPrint('Notification suppressed: app is currently open and visible ($title)');
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'pace_interval_channel',
        'Interval Transitions',
        channelDescription: 'Alerts when intervals start or complete in background',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Pace Interval Alert',
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: platformDetails,
      );
    } catch (e) {
      debugPrint('Show notification error: $e');
    }
  }
}

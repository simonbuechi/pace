import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv init warning: $e');
  }

  // Initialize local NoSQL database
  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('Hive init warning: $e');
  }

  // Initialize local notifications
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification init warning: $e');
  }

  runApp(
    const ProviderScope(
      child: PaceApp(),
    ),
  );
}

class PaceApp extends ConsumerWidget {
  const PaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final focusColor = ref.watch(activeFocusColorProvider);

    return MaterialApp(
      title: 'Pace Amigo',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light(focusColor),
      darkTheme: AppTheme.dark(focusColor),
      home: const HomeScreen(),
    );
  }
}

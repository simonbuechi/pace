import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pace_amigo/features/timer/providers/timer_provider.dart';
import 'package:pace_amigo/features/timer/ui/quick_start_screen.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('quick_start_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  testWidgets('QuickStartScreen renders fluid UI, presets, and updates values',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: QuickStartScreen(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify header and titles
    expect(find.text('Focus Duration'), findsOneWidget);

    // 2. Default initial values
    expect(find.text('25'), findsOneWidget); // Focus minutes
    expect(find.text('5'), findsOneWidget); // Break minutes
    expect(find.text('4'), findsOneWidget); // Cycles

    // 3. Preset chips exist
    expect(find.widgetWithText(ChoiceChip, '15m'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '45m'), findsOneWidget);

    // 4. Tap 15m preset chip
    await tester.tap(find.widgetWithText(ChoiceChip, '15m'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('15'), findsOneWidget);

    // 5. Verify Start Session CTA
    expect(find.text('Start Session'), findsOneWidget);
  });

  testWidgets(
      'QuickStartScreen shows active session card when timer is running',
      (WidgetTester tester) async {
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              home: Scaffold(
                body: QuickStartScreen(),
              ),
            );
          },
        ),
      ),
    );

    await tester.pump();

    // Initially no active session card
    expect(find.text('FOCUS SESSION'), findsNothing);

    // Start timer
    container.read(timerProvider.notifier).start();
    await tester.pump();

    // Now it displays live active session card
    expect(find.text('FOCUS SESSION'), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);
  });
}

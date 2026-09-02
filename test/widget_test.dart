import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pace_amigo/features/timer/providers/timer_provider.dart';
import 'package:pace_amigo/main.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('pace_test_');
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

  testWidgets('Pace Amigo smoke test - renders main navigation and header',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PaceApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify app title and navigation items are rendered
    expect(find.text('Pace Amigo'), findsWidgets);
    expect(find.text('Quick Start'), findsWidgets);
    expect(find.text('Routines'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    // Verify initial Title widget exists
    expect(find.byWidgetPredicate((w) => w is Title && w.title == 'Pace Amigo'), findsWidgets);
  });

  testWidgets('Browser tab title dynamically displays remaining time when timer runs',
      (WidgetTester tester) async {
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const PaceApp();
          },
        ),
      ),
    );

    await tester.pump();

    // Start the timer
    container.read(timerProvider.notifier).start();
    await tester.pump();

    // Verify Title widget now contains the formatted remaining time
    expect(
      find.byWidgetPredicate((w) => w is Title && w.title.startsWith('(25:00)')),
      findsOneWidget,
    );

    // Pause timer
    container.read(timerProvider.notifier).pause();
    await tester.pump();

    expect(
      find.byWidgetPredicate((w) => w is Title && w.title.contains('[Paused]')),
      findsOneWidget,
    );
  });
}

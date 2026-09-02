import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pace_amigo/main.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('pace_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
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
  });
}

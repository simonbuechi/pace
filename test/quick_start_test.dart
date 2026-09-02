import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
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

  testWidgets('QuickStartScreen displays defaults, removed presets, and editable fields',
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

    // 1. Verify default focus time is 5 min and break time is 1 min
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('1 min'), findsOneWidget);

    // 2. Verify preset chip buttons are removed
    expect(find.widgetWithText(ChoiceChip, '30s'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '15 m'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '25 m'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '45 m'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '60 m'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '3 m'), findsNothing);

    // 3. Verify interval cycles slider & default iterations
    expect(find.text('4 rounds'), findsOneWidget);
    // There should be 5 Sliders in total: focus min, focus sec, break min, break sec, cycles
    expect(find.byType(Slider), findsNWidgets(5));

    // 4. Verify editable number fields exist
    expect(find.byType(EditableValueField), findsNWidgets(5));
    expect(find.byType(TextField), findsNWidgets(5));

    // Check values in text fields: 5 (focus min), 0 (focus sec), 1 (break min), 0 (break sec), 4 (cycles)
    final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(textFields[0].controller?.text, '5');
    expect(textFields[1].controller?.text, '0');
    expect(textFields[2].controller?.text, '1');
    expect(textFields[3].controller?.text, '0');
    expect(textFields[4].controller?.text, '4');

    // 5. Test editing focus minutes directly via TextField
    await tester.enterText(find.byType(TextField).first, '12');
    await tester.pump();

    expect(find.text('12 min'), findsOneWidget);

    // 6. Test editing interval cycles directly via TextField
    await tester.enterText(find.byType(TextField).last, '25');
    await tester.pump();

    expect(find.text('25 rounds'), findsOneWidget);

    // 7. Verify Start Session button has 9025A7 to D81860 gradient
    final startButtonText = find.text('Start Session');
    expect(startButtonText, findsOneWidget);

    final containerFinder = find.ancestor(
      of: startButtonText,
      matching: find.byType(Container),
    );
    final container = tester.widget<Container>(containerFinder.first);
    final decoration = container.decoration as BoxDecoration?;
    expect(decoration?.gradient, isA<LinearGradient>());
    final gradient = decoration!.gradient as LinearGradient;
    expect(gradient.colors, [const Color(0xFF9025A7), const Color(0xFFD81860)]);
  });
}

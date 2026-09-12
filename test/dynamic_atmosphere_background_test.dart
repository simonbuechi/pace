import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pace_amigo/features/timer/ui/widgets/dynamic_atmosphere_background.dart';

void main() {
  group('DynamicAtmosphereBackground Widget & Palette Tests', () {
    test('AtmospherePalette focus, rest, and completed defaults are valid', () {
      final focus = AtmospherePalette.focus();
      expect(focus.breathPeriod, equals(4.0));
      expect(focus.orb1, isNotNull);
      expect(focus.orb2, isNotNull);
      expect(focus.haloColor, isNotNull);

      final rest = AtmospherePalette.rest();
      expect(rest.breathPeriod, equals(5.5));
      expect(rest.orb1, isNotNull);

      final completed = AtmospherePalette.completed();
      expect(completed.breathPeriod, equals(4.5));
      expect(completed.orb1, equals(const Color(0xFFF59E0B)));
    });

    test('AtmospherePalette.lerp correctly interpolates colors and breath periods', () {
      final a = AtmospherePalette.focus();
      final b = AtmospherePalette.rest();

      final mid = AtmospherePalette.lerp(a, b, 0.5);
      expect(mid.breathPeriod, closeTo(4.75, 0.01));
      expect(mid.baseTop, isNotNull);
    });

    testWidgets('Renders child inside DynamicAtmosphereBackground across states',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DynamicAtmosphereBackground(
            isRunning: true,
            isFocus: true,
            child: Scaffold(
              body: Text('Timer Visualizer'),
            ),
          ),
        ),
      );

      expect(find.text('Timer Visualizer'), findsOneWidget);
      expect(find.byType(DynamicAtmosphereBackground), findsOneWidget);

      // Advance frames to ensure ticker & custom painter run smoothly without exception
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Timer Visualizer'), findsOneWidget);
    });

    testWidgets('Smoothly handles transition from focus to rest and completion',
        (tester) async {
      bool isFocus = true;
      bool isCompleted = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: DynamicAtmosphereBackground(
                isRunning: true,
                isFocus: isFocus,
                isCompleted: isCompleted,
                child: Column(
                  children: [
                    const Text('Content Area'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isFocus = false;
                        });
                      },
                      child: const Text('Switch to Rest'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isCompleted = true;
                        });
                      },
                      child: const Text('Complete Session'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Content Area'), findsOneWidget);

      // Switch to rest phase
      await tester.tap(find.text('Switch to Rest'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 900));

      // Switch to completed
      await tester.tap(find.text('Complete Session'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Content Area'), findsOneWidget);
    });
  });
}

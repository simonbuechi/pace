import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pace_amigo/core/services/pwa_service.dart';
import 'package:pace_amigo/main.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('pace_test_desk_');
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

  testWidgets('PaceApp renders on desktop 1280x800 without errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pwaProvider.overrideWith(
            (ref) => PwaNotifier()..state = const PwaState(
              isWeb: true,
              isStandalone: false,
              isDismissed: false,
            ),
          ),
        ],
        child: const PaceApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}

import 'package:bloom_play/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

/// Drives the app across the key screens and captures a screenshot of each.
/// Uses fixed pumps (not pumpAndSettle) on always-animating screens so the
/// harness never times out waiting for particle / mascot loops to settle.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture key screens', (tester) async {
    // Start from a clean slate so onboarding shows deterministically.
    await Hive.initFlutter();
    final prefs = await Hive.openBox('prefs');
    await prefs.clear();
    await Hive.box('prefs').close();

    final overrides = await buildOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const BloomPlayApp()),
    );
    await tester.pump(const Duration(milliseconds: 700));

    Future<void> shoot(String name) async {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump(const Duration(milliseconds: 300));
      await binding.takeScreenshot(name);
    }

    // 01 - Onboarding.
    await shoot('01-onboarding');

    // Start playing -> home.
    await tester.tap(find.text('Start Playing'));
    await tester.pump(const Duration(milliseconds: 700));
    await shoot('02-home');

    // Open the "continue" lesson (drag & target on lesson 2 by default, but
    // whatever the current lesson is) via the hero Play button.
    await tester.tap(find.text('Play').first);
    await tester.pump(const Duration(milliseconds: 800));
    await shoot('03-lesson-player');

    // Finish it with the demo done button -> celebration.
    await tester.tap(find.byTooltip('Mark done (demo)'));
    await tester.pump(const Duration(milliseconds: 900));
    await shoot('04-celebration');

    // Home, then the other tabs.
    await tester.tap(find.text('Home').last);
    await tester.pump(const Duration(milliseconds: 600));

    await _goTab(tester, 'Play');
    await shoot('05-playground');

    await _goTab(tester, 'Closet');
    await shoot('06-closet');

    await _goTab(tester, 'Progress');
    await shoot('07-progress');
  });
}

Future<void> _goTab(WidgetTester tester, String label) async {
  // Tap the bottom-nav item (last match = the nav bar, not any hero copy).
  await tester.tap(find.text(label).last);
  await tester.pump(const Duration(milliseconds: 700));
}

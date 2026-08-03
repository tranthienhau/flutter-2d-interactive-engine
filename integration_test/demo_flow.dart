import 'package:bloom_play/app.dart';
import 'package:bloom_play/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

/// A slower, interaction-rich walkthrough recorded as the demo GIF: onboarding
/// -> home -> a live lesson -> celebration -> playground -> closet -> progress.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo flow', (tester) async {
    await Hive.initFlutter();
    final prefs = await Hive.openBox('prefs');
    await prefs.clear();
    await Hive.box('prefs').close();

    final overrides = await buildOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const BloomPlayApp()),
    );

    Future<void> beat([int ms = 900]) =>
        tester.pump(Duration(milliseconds: ms));

    await beat(1200); // onboarding

    // Pick a different buddy, then start.
    await tester.tap(find.text('Pip'));
    await beat();
    await tester.tap(find.text('Start Playing'));
    await beat(1200); // home

    // Open the current lesson (Day and Night = state toggle).
    await tester.tap(find.text('Play').first);
    await beat(1200); // lesson player

    // Interact: tap the sky to flip to night (this solves the lesson).
    await tester.tapAt(tester.getCenter(find.byType(MaterialApp)));
    await beat(1600); // celebration with particles
    await beat(1400);

    // Back home, then tour the tabs.
    await tester.tap(find.text('Home').last);
    await beat(1100);

    await tester.tap(find.text('Play').last);
    await beat(1100); // playground

    await tester.tap(find.text('Closet').last);
    await beat(1100); // closet
    // Equip a costume.
    await tester.tap(find.text('Wear it!'));
    await beat(1200);

    await tester.tap(find.text('Progress').last);
    await beat(1400); // progress
  });
}

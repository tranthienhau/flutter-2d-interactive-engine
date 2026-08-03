import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Writes each PNG captured by `binding.takeScreenshot(name)` into
/// `screenshots/<name>.png`.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final dir = Directory('screenshots');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('screenshots/$name.png');
      file.writeAsBytesSync(bytes);
      return true;
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/persistence/local_store.dart';
import 'router/app_router.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';

/// Root widget. Reads the injected [LocalStore] to seed the router.
class BloomPlayApp extends ConsumerWidget {
  const BloomPlayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(localStoreProvider);
    final router = buildRouter(store);
    return MaterialApp.router(
      title: 'Bloom Play',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}

/// Boots persistence and returns the overrides needed by [ProviderScope].
Future<List<Override>> buildOverrides() async {
  final store = await LocalStore.open();
  return [localStoreProvider.overrideWithValue(store)];
}

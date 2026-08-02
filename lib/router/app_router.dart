import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/persistence/local_store.dart';
import '../screens/closet_screen.dart';
import '../screens/home_map_screen.dart';
import '../screens/lesson_complete_screen.dart';
import '../screens/lesson_player_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/playground_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/nav_scaffold.dart';

/// The navigation shell: an onboarding gate, a 4-tab ShellRoute for the core
/// screens, and full-screen routes for the lesson player, celebration, and
/// settings.
GoRouter buildRouter(LocalStore store) {
  return GoRouter(
    initialLocation: store.onboarded ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            NavScaffold(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeMapScreen(),
            routes: [
              // Settings hangs off home so its close returns cleanly.
              GoRoute(
                path: 'settings',
                parentNavigatorKey: _rootKey,
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/playground',
            builder: (_, __) => const PlaygroundScreen(),
          ),
          GoRoute(
            path: '/closet',
            builder: (_, __) => const ClosetScreen(),
          ),
          GoRoute(
            path: '/progress',
            builder: (_, __) => const ProgressScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/lesson/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            LessonPlayerScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/complete/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => LessonCompleteScreen(
          lessonId: state.pathParameters['id']!,
          stars: int.tryParse(state.uri.queryParameters['stars'] ?? '3') ?? 3,
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
    navigatorKey: _rootKey,
  );
}

final _rootKey = GlobalKey<NavigatorState>();

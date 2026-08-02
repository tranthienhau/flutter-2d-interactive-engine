import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// The one shared bottom tab bar concept, reused verbatim on every core
/// screen: Home, Play, Closet, Progress. Matches design/DESIGN.md.
class NavScaffold extends StatelessWidget {
  const NavScaffold({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _tabs = [
    (label: 'Home', icon: Icons.home_rounded, route: '/home'),
    (label: 'Play', icon: Icons.category_rounded, route: '/playground'),
    (label: 'Closet', icon: Icons.checkroom_rounded, route: '/closet'),
    (label: 'Progress', icon: Icons.auto_graph_rounded, route: '/progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final t in _tabs)
              _TabItem(
                label: t.label,
                icon: t.icon,
                active: location == t.route,
                onTap: () => context.go(t.route),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.textTertiary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 8, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.accentTint : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(label,
                style: AppText.caption
                    .copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Big rounded pill primary button (min height 56 for little fingers).
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.secondary = false,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool secondary;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = secondary ? AppColors.accentTint : (color ?? AppColors.accent);
    final fg = secondary ? AppColors.accent : Colors.white;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: secondary ? null : AppShadows.soft,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 22),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: AppText.label.copyWith(color: fg, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft white rounded card (radius 20, soft shadow).
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding, this.color});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}

/// A small row of filled/empty stars used for lesson scores.
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.filled, this.total = 3, this.size = 20});
  final int filled;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < total; i++)
          Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.support,
            size: size,
          ),
      ],
    );
  }
}

/// The soft accent -> support gradient used on hero surfaces.
const kHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.accent, AppColors.support],
);

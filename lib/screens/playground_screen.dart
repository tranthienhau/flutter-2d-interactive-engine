import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../mechanics/mechanic.dart';
import '../mechanics/mechanic_registry.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Mechanic Playground - a sandbox of all 7 templates. Matches
/// design/05-mechanic-playground. Tapping a tile opens that mechanic live.
class PlaygroundScreen extends ConsumerWidget {
  const PlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = MechanicType.values;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Playground', style: AppText.display),
          Text('Try every mechanic', style: AppText.caption),
          const SizedBox(height: 16),
          // Featured focal tile.
          _FeatureTile(
            type: MechanicType.pathTracing,
            onTap: () => _open(context, ref, MechanicType.pathTracing),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.05,
            children: [
              for (final t in all)
                if (t != MechanicType.pathTracing)
                  _MechTile(type: t, onTap: () => _open(context, ref, t)),
            ],
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref, MechanicType type) {
    final audio = ref.read(audioProvider);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(dialogCtx).size.height * 0.7,
            child: Stack(
              children: [
                Positioned.fill(
                  child: buildMechanic(
                    type,
                    MechanicContext(
                      audio: audio,
                      onSolved: (_) => Navigator.of(dialogCtx).pop(),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.type, required this.onTap});
  final MechanicType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: kHeroGradient,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: [
            Icon(type.icon, size: 56, color: Colors.white),
            const SizedBox(height: 10),
            Text(type.title,
                style: AppText.title.copyWith(color: Colors.white)),
            Text(type.blurb,
                style: AppText.caption.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _MechTile extends StatelessWidget {
  const _MechTile({required this.type, required this.onTap});
  final MechanicType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.accentTint,
              child: Icon(type.icon, color: AppColors.accent, size: 26),
            ),
            const SizedBox(height: 10),
            Text(type.title,
                textAlign: TextAlign.center, style: AppText.label),
            Text(type.blurb,
                textAlign: TextAlign.center, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}

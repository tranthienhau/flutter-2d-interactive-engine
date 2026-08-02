import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/rive/costume_bridge.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Costume Closet - dress the mascot via the Rive bridge. Matches
/// design/06-costume-closet.
class ClosetScreen extends ConsumerStatefulWidget {
  const ClosetScreen({super.key});

  @override
  ConsumerState<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends ConsumerState<ClosetScreen> {
  String _category = kCostumeCategories.first;
  Costume? _selected;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final bridge = ref.watch(costumeBridgeProvider);
    final items =
        kCostumes.where((c) => c.category == _category).toList();
    final selected = _selected ??
        kCostumes.firstWhere(
          (c) => c.id == progress.equippedId,
          orElse: () => kCostumes.first,
        );

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Mascot preview on a spotlight disc.
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [AppColors.accentTint, AppColors.background],
                radius: 0.9,
              ),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: RiveMascot(bridge: bridge, size: 150),
          ),
          const SizedBox(height: 12),
          // Category chips.
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final cat in kCostumeCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: _category == cat,
                      onSelected: (_) => setState(() => _category = cat),
                      selectedColor: AppColors.support,
                      backgroundColor: AppColors.surface,
                      labelStyle: AppText.label.copyWith(
                        color: _category == cat
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final c in items)
                  _CostumeTile(
                    costume: c,
                    available: progress.isAvailable(c),
                    selected: selected.id == c.id,
                    onTap: progress.isAvailable(c)
                        ? () => setState(() => _selected = c)
                        : null,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: PillButton(
                label: 'Wear it!',
                icon: Icons.check_circle_rounded,
                onTap: () {
                  ref
                      .read(progressProvider.notifier)
                      .equip(selected.id);
                  bridge.equipSkin(selected.id, selected.color);
                  ref.read(audioProvider).playSfx('equip');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostumeTile extends StatelessWidget {
  const _CostumeTile({
    required this.costume,
    required this.available,
    required this.selected,
    required this.onTap,
  });

  final Costume costume;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 3 : 1,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                available ? Icons.checkroom_rounded : Icons.lock_rounded,
                color: available ? costume.color : AppColors.textTertiary,
                size: 34,
              ),
            ),
            if (!available)
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.support),
                    Text('${costume.starCost}', style: AppText.caption),
                  ],
                ),
              ),
            if (selected)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

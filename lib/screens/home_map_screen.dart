import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Home - the winding lesson map. Matches design/02-home-lesson-map.
class HomeMapScreen extends ConsumerWidget {
  const HomeMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final store = ref.watch(localStoreProvider);
    final currentIndex = progress.currentIndex;
    final current = kLessons[currentIndex];

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top playful bar.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.accentTint,
                  child: const Icon(Icons.pets, color: AppColors.accent),
                ),
                const SizedBox(width: 10),
                Text(store.childName, style: AppText.title),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.supportTint,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.support, size: 20),
                      const SizedBox(width: 4),
                      Text('${progress.totalStars}',
                          style: AppText.label
                              .copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                // Focal continue card.
                GestureDetector(
                  onTap: () => context.push('/lesson/${current.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: kHeroGradient,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Up Next',
                                  style: AppText.caption
                                      .copyWith(color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text(
                                'Lesson ${currentIndex + 1}: ${current.title}',
                                style: AppText.title
                                    .copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              PillButton(
                                label: 'Play',
                                icon: Icons.play_arrow_rounded,
                                secondary: true,
                                onTap: () =>
                                    context.push('/lesson/${current.id}'),
                              ),
                            ],
                          ),
                        ),
                        Icon(current.icon,
                            size: 56, color: Colors.white.withValues(alpha: 0.9)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // The lesson path.
                for (int i = 0; i < kLessons.length; i++)
                  _LessonNode(
                    lesson: kLessons[i],
                    index: i,
                    stars: progress.starsFor(kLessons[i].id),
                    state: i < currentIndex
                        ? _NodeState.done
                        : (i == currentIndex
                            ? _NodeState.current
                            : _NodeState.locked),
                    alignRight: i.isOdd,
                    onTap: i <= currentIndex
                        ? () => context.push('/lesson/${kLessons[i].id}')
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NodeState { done, current, locked }

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.lesson,
    required this.index,
    required this.stars,
    required this.state,
    required this.alignRight,
    required this.onTap,
  });

  final Lesson lesson;
  final int index;
  final int stars;
  final _NodeState state;
  final bool alignRight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Widget badge;
    switch (state) {
      case _NodeState.done:
        bg = AppColors.support;
        badge = const Icon(Icons.check_rounded, color: Colors.white, size: 30);
        break;
      case _NodeState.current:
        bg = AppColors.accent;
        badge =
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34);
        break;
      case _NodeState.locked:
        bg = AppColors.surfaceAlt;
        badge = const Icon(Icons.lock_rounded,
            color: AppColors.textTertiary, size: 24);
        break;
    }
    final node = GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: state == _NodeState.current ? 84 : 68,
            height: state == _NodeState.current ? 84 : 68,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: state == _NodeState.locked ? null : AppShadows.soft,
            ),
            child: Center(child: badge),
          ),
          const SizedBox(height: 4),
          if (state != _NodeState.locked) StarRow(filled: stars, size: 14),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (alignRight) const Spacer(),
          if (!alignRight) const SizedBox(width: 24),
          node,
          if (!alignRight) const Spacer(),
          if (alignRight) const SizedBox(width: 24),
        ],
      ),
    );
  }
}

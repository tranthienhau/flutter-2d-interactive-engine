import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Parent progress dashboard. Matches design/07-progress-dashboard: a big
/// completion ring, weekly play-time bars, per-skill bars, recent lessons.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final store = ref.watch(localStoreProvider);
    final pct = progress.completedCount / kLessons.length;

    // Aggregate stars per skill for the skill bars.
    final skills = <String, int>{};
    final skillMax = <String, int>{};
    for (final l in kLessons) {
      skills[l.skill] = (skills[l.skill] ?? 0) + progress.starsFor(l.id);
      skillMax[l.skill] = (skillMax[l.skill] ?? 0) + 3;
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text("${store.childName}'s Progress", style: AppText.display),
          const SizedBox(height: 16),
          // Focal ring.
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: CircularProgressIndicator(
                          value: pct == 0 ? 0.02 : pct,
                          strokeWidth: 14,
                          backgroundColor: AppColors.surfaceAlt,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.accent),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(pct * 100).round()}%',
                              style: AppText.display.copyWith(
                                  fontSize: 40, color: AppColors.accent)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    '${progress.completedCount} of ${kLessons.length} lessons completed',
                    style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Weekly play time (mock but stable).
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Play Time', style: AppText.title),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final e in const [
                        ('M', 0.4),
                        ('T', 0.6),
                        ('W', 0.8),
                        ('T', 0.3),
                        ('F', 0.9),
                        ('S', 0.5),
                        ('S', 0.2),
                      ])
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                height: 90 * e.$2,
                                decoration: BoxDecoration(
                                  color: AppColors.support,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(e.$1, style: AppText.caption),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Skill bars.
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Skills', style: AppText.title),
                const SizedBox(height: 12),
                for (final entry in skills.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: AppText.body),
                            Text(
                              '${((entry.value / (skillMax[entry.key] ?? 1)) * 100).round()}%',
                              style: AppText.label
                                  .copyWith(color: AppColors.accent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: entry.value / (skillMax[entry.key] ?? 1),
                            minHeight: 10,
                            backgroundColor: AppColors.surfaceAlt,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Recent lessons.
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Lessons', style: AppText.title),
                const SizedBox(height: 8),
                for (final l in kLessons.where((l) => progress.isCompleted(l.id)))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.supportTint,
                          child: Icon(l.icon, color: AppColors.support),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(l.title, style: AppText.body)),
                        StarRow(filled: progress.starsFor(l.id), size: 18),
                      ],
                    ),
                  ),
                if (progress.completedCount == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('No lessons yet - go play!',
                        style: AppText.caption),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

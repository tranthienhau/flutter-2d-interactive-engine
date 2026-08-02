import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/particles/particle_emitter.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Lesson complete celebration. Matches design/lesson-complete: particle
/// burst, mascot cheer, star award, and a costume-unlock reward card.
class LessonCompleteScreen extends ConsumerStatefulWidget {
  const LessonCompleteScreen({
    super.key,
    required this.lessonId,
    required this.stars,
  });

  final String lessonId;
  final int stars;

  @override
  ConsumerState<LessonCompleteScreen> createState() =>
      _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends ConsumerState<LessonCompleteScreen> {
  Costume? _reward;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bridge = ref.read(costumeBridgeProvider);
      bridge.triggerRandomReaction();
      ref.read(audioProvider).playSfx('fanfare');
      // Surface the first newly-affordable locked costume as the reward.
      final progress = ref.read(progressProvider);
      for (final c in kCostumes) {
        if (progress.totalStars >= c.starCost && c.starCost > 0) {
          setState(() => _reward = c);
          break;
        }
      }
    });
  }

  int get _index =>
      kLessons.indexWhere((l) => l.id == widget.lessonId).clamp(0, 9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: kHeroGradient),
          ),
          const Positioned.fill(child: ParticleBurst()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Icon(Icons.emoji_events_rounded,
                      size: 96, color: Colors.white.withValues(alpha: 0.95)),
                  const SizedBox(height: 12),
                  Text('${widget.stars} Stars!',
                      style:
                          AppText.display.copyWith(color: Colors.white, fontSize: 40)),
                  const SizedBox(height: 8),
                  StarRow(filled: widget.stars, size: 40),
                  const SizedBox(height: 24),
                  if (_reward != null)
                    SoftCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                _reward!.color.withValues(alpha: 0.18),
                            child: Icon(Icons.card_giftcard_rounded,
                                color: _reward!.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('New costume unlocked!',
                                    style: AppText.caption),
                                Text(_reward!.name, style: AppText.title),
                              ],
                            ),
                          ),
                          const Icon(Icons.auto_awesome_rounded,
                              color: AppColors.support),
                        ],
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: PillButton(
                      label: 'Next Lesson',
                      icon: Icons.arrow_forward_rounded,
                      onTap: () {
                        final next = (_index + 1).clamp(0, kLessons.length - 1);
                        context.pushReplacement('/lesson/${kLessons[next].id}');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: PillButton(
                      label: 'Home',
                      secondary: true,
                      onTap: () => context.go('/home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

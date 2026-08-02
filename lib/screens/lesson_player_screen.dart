import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../mechanics/mechanic.dart';
import '../mechanics/mechanic_registry.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

/// Lesson player - the fullscreen interactive canvas. Matches
/// design/03-lesson-player. Hosts one mechanic and reports the result.
class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  late final Lesson _lesson;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _lesson = kLessons.firstWhere((l) => l.id == widget.lessonId,
        orElse: () => kLessons.first);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioProvider).playVoice('vo_${_lesson.id}');
    });
  }

  Future<void> _onSolved(int stars) async {
    if (_solved) return;
    _solved = true;
    await ref
        .read(progressProvider.notifier)
        .completeLesson(_lesson.id, stars);
    if (mounted) {
      context.pushReplacement('/complete/${_lesson.id}?stars=$stars');
    }
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioProvider);
    final ctx = MechanicContext(audio: audio, onSolved: _onSolved);
    final index = kLessons.indexOf(_lesson);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: buildMechanic(_lesson.mechanic, ctx)),
          // Top HUD.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      _RoundButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.go('/home'),
                      ),
                      const Spacer(),
                      _ProgressPips(current: 2, total: 5),
                      const Spacer(),
                      _RoundButton(
                        icon: Icons.volume_up_rounded,
                        onTap: () => audio.playVoice('vo_${_lesson.id}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Instruction ribbon.
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.record_voice_over_rounded,
                            color: AppColors.accent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(_lesson.instruction,
                              style: AppText.label
                                  .copyWith(color: AppColors.accent)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Skip helper (demo affordance so a lesson is always finishable).
          Positioned(
            right: 16,
            bottom: 24,
            child: Opacity(
              opacity: 0.9,
              child: _RoundButton(
                icon: Icons.check_rounded,
                color: AppColors.success,
                onTap: () => _onSolved(3),
                tooltip: 'Mark done (demo)',
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 24,
            child: Text('Lesson ${index + 1}',
                style: AppText.caption.copyWith(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, color: color ?? AppColors.accent),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class _ProgressPips extends StatelessWidget {
  const _ProgressPips({required this.current, required this.total});
  final int current, total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < total; i++)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < current ? AppColors.accent : AppColors.accentTint,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/responsive/stage.dart';
import '../theme/app_theme.dart';
import 'mechanic.dart';

/// Template 1 - State Toggle. Tap the scene to flip between two discrete
/// states (day <-> night). Solved when the child reaches the target state.
class StateToggleMechanic extends MechanicWidget {
  const StateToggleMechanic({super.key, required super.ctx});

  @override
  State<StateToggleMechanic> createState() => _StateToggleMechanicState();
}

class _StateToggleMechanicState extends State<StateToggleMechanic> {
  bool _night = false;
  bool _done = false;

  void _toggle() {
    setState(() => _night = !_night);
    widget.ctx.audio.playSfx('toggle');
    if (_night && !_done) {
      _done = true;
      widget.ctx.audio.playSfx('success');
      Future.delayed(const Duration(milliseconds: 500),
          () => widget.ctx.onSolved(3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StageBuilder(
      builder: (context, stage) {
        return GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _night
                    ? const [Color(0xFF2A2350), Color(0xFF4B3F82)]
                    : const [Color(0xFFBFE3FF), Color(0xFFEAF6FF)],
              ),
            ),
            child: Stack(
              children: [
                // Sun / moon positioned by relative fraction - stays on-screen
                // on any aspect ratio.
                StageBox(
                  stage: stage,
                  left: 0.5,
                  top: 0.3,
                  square: 0.28,
                  align: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _night ? const Color(0xFFF3EED6) : AppColors.support,
                      boxShadow: [
                        BoxShadow(
                          color: (_night ? Colors.white : AppColors.support)
                              .withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: stage.height * 0.12,
                  child: Center(
                    child: Text(
                      _night ? 'Good night!' : 'Tap the sky',
                      style: AppText.title.copyWith(
                        color: _night ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/responsive/stage.dart';
import '../theme/app_theme.dart';
import 'mechanic.dart';

/// Template 6 - Tap & Hold. Press and keep holding to charge a value to full
/// (grow the flower). Releasing early lets it shrink back. Solved at full.
class TapHoldMechanic extends MechanicWidget {
  const TapHoldMechanic({super.key, required super.ctx});

  @override
  State<TapHoldMechanic> createState() => _TapHoldMechanicState();
}

class _TapHoldMechanicState extends State<TapHoldMechanic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(() {
        setState(() {});
        if (_c.value >= 1.0 && !_done) {
          _done = true;
          widget.ctx.audio.playSfx('success');
          Future.delayed(const Duration(milliseconds: 400),
              () => widget.ctx.onSolved(3));
        }
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _hold(bool down) {
    if (_done) return;
    if (down) {
      widget.ctx.audio.playSfx('grow');
      _c.forward();
    } else {
      _c.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StageBuilder(
      builder: (context, stage) {
        return GestureDetector(
          onTapDown: (_) => _hold(true),
          onTapUp: (_) => _hold(false),
          onTapCancel: () => _hold(false),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFDDF4FF), Color(0xFFE9F7EC)],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FlowerPainter(_c.value),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: stage.height * 0.05,
                  child: Center(
                    child: Text(
                      _done ? 'It bloomed!' : 'Press and hold to grow',
                      style: AppText.title,
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

class _FlowerPainter extends CustomPainter {
  _FlowerPainter(this.t);
  final double t; // 0..1 growth

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final baseY = h * 0.9;
    final stemTop = baseY - (h * 0.55) * t;
    // Stem
    final stem = Paint()
      ..color = AppColors.success
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w / 2, baseY), Offset(w / 2, stemTop), stem);
    // Bloom scales with t
    final r = (w * 0.02) + (w * 0.13) * t;
    final petal = Paint()..color = const Color(0xFFF5477E);
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final c = Offset(
          w / 2 + r * 1.1 * math.cos(a), stemTop + r * 1.1 * math.sin(a));
      canvas.drawCircle(c, r * 0.7, petal);
    }
    canvas.drawCircle(
        Offset(w / 2, stemTop), r * 0.7, Paint()..color = AppColors.support);
  }

  @override
  bool shouldRepaint(covariant _FlowerPainter old) => old.t != t;
}

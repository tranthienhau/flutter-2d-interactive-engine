import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/responsive/stage.dart';
import '../theme/app_theme.dart';
import 'mechanic.dart';

class _Bubble {
  _Bubble(this.fx, this.fy, this.r, this.color, this.driftPhase);
  double fx; // fractional position
  double fy;
  final double r; // fraction of short side
  final Color color;
  final double driftPhase;
  bool popped = false;
}

/// Template 7 - Physics Spawn. Spawns floaty targets that drift with a cheap
/// sine bob (no real physics sim); tap to pop. Solved when the quota is popped.
class PhysicsSpawnMechanic extends MechanicWidget {
  const PhysicsSpawnMechanic({super.key, required super.ctx});

  @override
  State<PhysicsSpawnMechanic> createState() => _PhysicsSpawnMechanicState();
}

class _PhysicsSpawnMechanicState extends State<PhysicsSpawnMechanic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final _rnd = math.Random(11);
  late final List<_Bubble> _bubbles;
  int _popped = 0;
  static const _quota = 5;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _bubbles = List.generate(_quota, (i) {
      final colors = [
        AppColors.accent,
        AppColors.support,
        const Color(0xFFF5477E),
        const Color(0xFF0EA5C4),
        const Color(0xFF16A34A),
      ];
      return _Bubble(
        0.15 + _rnd.nextDouble() * 0.7,
        0.25 + _rnd.nextDouble() * 0.5,
        0.09 + _rnd.nextDouble() * 0.04,
        colors[i % colors.length],
        _rnd.nextDouble() * math.pi * 2,
      );
    });
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _tapAt(Stage stage, Offset localFrac) {
    for (final b in _bubbles) {
      if (b.popped) continue;
      final bobY = b.fy + math.sin(_c.value * 2 * math.pi + b.driftPhase) * 0.04;
      final centre = stage.px(b.fx, bobY);
      final tap = stage.px(localFrac.dx, localFrac.dy);
      if ((centre - tap).distance <= stage.square(b.r)) {
        setState(() {
          b.popped = true;
          _popped++;
        });
        widget.ctx.audio.playSfx('pop');
        if (_popped >= _quota && !_done) {
          _done = true;
          widget.ctx.audio.playSfx('success');
          Future.delayed(const Duration(milliseconds: 400),
              () => widget.ctx.onSolved(3));
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StageBuilder(
      builder: (context, stage) {
        return GestureDetector(
          onTapDown: (d) {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(d.globalPosition);
            _tapAt(stage, Offset(local.dx / stage.width, local.dy / stage.height));
          },
          child: Container(
            color: const Color(0xFFEAF6FF),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BubblePainter(_bubbles, _c.value),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: stage.height * 0.05,
                  child: Center(
                    child: Text('Popped $_popped / $_quota',
                        style: AppText.title),
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

class _BubblePainter extends CustomPainter {
  _BubblePainter(this.bubbles, this.t);
  final List<_Bubble> bubbles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final minSide = size.shortestSide;
    for (final b in bubbles) {
      if (b.popped) continue;
      final bobY = b.fy + math.sin(t * 2 * math.pi + b.driftPhase) * 0.04;
      final c = Offset(b.fx * size.width, bobY * size.height);
      final r = b.r * minSide;
      canvas.drawCircle(c, r, Paint()..color = b.color.withValues(alpha: 0.85));
      canvas.drawCircle(
        c.translate(-r * 0.3, -r * 0.3),
        r * 0.25,
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => true;
}

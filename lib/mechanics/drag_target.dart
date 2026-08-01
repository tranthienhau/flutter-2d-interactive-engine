import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/responsive/stage.dart';
import '../theme/app_theme.dart';
import 'mechanic.dart';

enum _ShapeKind { star, circle, square }

class _Token {
  _Token(this.kind, this.color, this.slotFx, this.slotFy);
  final _ShapeKind kind;
  final Color color;
  final double slotFx; // target slot centre (fraction)
  final double slotFy;
  Offset? dragFx; // current fractional position while dragging / placed
  bool placed = false;
}

/// Template 2 - Drag & Target with collision. Drag each shape token onto its
/// matching outlined slot; a fractional hit-test decides a correct drop.
/// Solved when every token is placed.
class DragTargetMechanic extends MechanicWidget {
  const DragTargetMechanic({super.key, required super.ctx});

  @override
  State<DragTargetMechanic> createState() => _DragTargetMechanicState();
}

class _DragTargetMechanicState extends State<DragTargetMechanic> {
  late final List<_Token> _tokens;

  @override
  void initState() {
    super.initState();
    _tokens = [
      _Token(_ShapeKind.star, AppColors.support, 0.25, 0.28),
      _Token(_ShapeKind.circle, AppColors.accent, 0.5, 0.28),
      _Token(_ShapeKind.square, const Color(0xFFF5477E), 0.75, 0.28),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StageBuilder(
      builder: (context, stage) {
        final tokenSq = 0.16; // fraction of short side
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE9F7EC), Color(0xFFF6F4FD)],
            ),
          ),
          child: Stack(
            children: [
              // Target slots (outlined) at the top.
              for (final t in _tokens)
                StageBox(
                  stage: stage,
                  left: t.slotFx,
                  top: t.slotFy,
                  square: tokenSq + 0.02,
                  align: Alignment.center,
                  child: _ShapeView(kind: t.kind, color: t.color.withValues(alpha: 0.25), outline: true),
                ),
              // Draggable tokens - start along the bottom.
              for (int i = 0; i < _tokens.length; i++)
                _buildToken(stage, _tokens[i], i, tokenSq),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToken(Stage stage, _Token t, int i, double tokenSq) {
    final startFx = 0.25 + i * 0.25;
    final posFx = t.dragFx ?? Offset(startFx, 0.8);
    return StageBox(
      stage: stage,
      left: posFx.dx,
      top: posFx.dy,
      square: tokenSq,
      align: Alignment.center,
      child: IgnorePointer(
        ignoring: t.placed,
        child: GestureDetector(
          onPanUpdate: (d) {
            setState(() {
              final cur = t.dragFx ?? Offset(startFx, 0.8);
              t.dragFx = Offset(
                cur.dx + d.delta.dx / stage.width,
                cur.dy + d.delta.dy / stage.height,
              );
            });
          },
          onPanEnd: (_) => _tryPlace(stage, t, tokenSq),
          child: _ShapeView(kind: t.kind, color: t.color, outline: false),
        ),
      ),
    );
  }

  void _tryPlace(Stage stage, _Token t, double tokenSq) {
    final cur = t.dragFx;
    if (cur == null) return;
    final tokenCentrePx = stage.px(cur.dx, cur.dy);
    final slotSize = stage.square(tokenSq + 0.06);
    final slotCentre = stage.px(t.slotFx, t.slotFy);
    final slotRect = Rect.fromCenter(
        center: slotCentre, width: slotSize, height: slotSize);
    if (stage.hit(tokenCentrePx, slotRect)) {
      setState(() {
        t.dragFx = Offset(t.slotFx, t.slotFy); // snap
        t.placed = true;
      });
      widget.ctx.audio.playSfx('snap');
      if (_tokens.every((e) => e.placed)) {
        widget.ctx.audio.playSfx('success');
        Future.delayed(const Duration(milliseconds: 500),
            () => widget.ctx.onSolved(3));
      }
    } else {
      setState(() => t.dragFx = Offset(0.25 + _tokens.indexOf(t) * 0.25, 0.8));
    }
  }
}

class _ShapeView extends StatelessWidget {
  const _ShapeView({required this.kind, required this.color, required this.outline});
  final _ShapeKind kind;
  final Color color;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapePainter(kind, color, outline),
      size: Size.infinite,
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.kind, this.color, this.outline);
  final _ShapeKind kind;
  final Color color;
  final bool outline;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = outline ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 4
      ..isAntiAlias = true;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 * 0.9;
    switch (kind) {
      case _ShapeKind.circle:
        canvas.drawCircle(c, r, p);
        break;
      case _ShapeKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: r * 1.7, height: r * 1.7),
            const Radius.circular(10),
          ),
          p,
        );
        break;
      case _ShapeKind.star:
        canvas.drawPath(_star(c, r), p);
        break;
    }
  }

  Path _star(Offset c, double r) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final o = -math.pi / 2 + i * 2 * math.pi / 5;
      final inner = o + math.pi / 5;
      final op = Offset(c.dx + r * math.cos(o), c.dy + r * math.sin(o));
      final ip = Offset(
          c.dx + r * 0.45 * math.cos(inner), c.dy + r * 0.45 * math.sin(inner));
      if (i == 0) {
        path.moveTo(op.dx, op.dy);
      } else {
        path.lineTo(op.dx, op.dy);
      }
      path.lineTo(ip.dx, ip.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) =>
      old.color != color || old.outline != outline || old.kind != kind;
}

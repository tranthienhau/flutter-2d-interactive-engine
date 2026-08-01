import 'package:flutter/material.dart';

import '../core/responsive/stage.dart';
import '../theme/app_theme.dart';
import 'mechanic.dart';

/// Template 5 - Path Tracing. A dotted guide path (the letter A) is defined as
/// ordered fractional waypoints; the child must drag through them in sequence.
/// Solved when the final waypoint is reached.
class PathTracingMechanic extends MechanicWidget {
  const PathTracingMechanic({super.key, required super.ctx});

  @override
  State<PathTracingMechanic> createState() => _PathTracingMechanicState();
}

class _PathTracingMechanicState extends State<PathTracingMechanic> {
  // Letter A as three strokes worth of ordered waypoints (fractional).
  static const _waypoints = <Offset>[
    Offset(0.5, 0.2),
    Offset(0.38, 0.5),
    Offset(0.26, 0.8),
    Offset(0.5, 0.2),
    Offset(0.62, 0.5),
    Offset(0.74, 0.8),
    Offset(0.62, 0.5), // cross-bar start
    Offset(0.38, 0.5), // cross-bar end
  ];
  int _reached = 0; // how many waypoints hit, in order
  bool _done = false;

  void _onMove(Stage stage, Offset globalToLocalFrac) {
    if (_reached >= _waypoints.length) return;
    final next = _waypoints[_reached];
    final dPx = (stage.px(globalToLocalFrac.dx, globalToLocalFrac.dy) -
            stage.px(next.dx, next.dy))
        .distance;
    if (dPx < stage.minSide * 0.12) {
      setState(() => _reached++);
      widget.ctx.audio.playSfx('trace');
      if (_reached >= _waypoints.length && !_done) {
        _done = true;
        widget.ctx.audio.playSfx('success');
        Future.delayed(const Duration(milliseconds: 400),
            () => widget.ctx.onSolved(3));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StageBuilder(
      builder: (context, stage) {
        void handle(Offset globalPos) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          final local = box.globalToLocal(globalPos);
          _onMove(stage, Offset(local.dx / stage.width, local.dy / stage.height));
        }

        return GestureDetector(
          onPanStart: (d) => handle(d.globalPosition),
          onPanUpdate: (d) => handle(d.globalPosition),
          child: Container(
            color: AppColors.background,
            child: Stack(
              children: [
                CustomPaint(
                  painter: _TracePainter(_waypoints, _reached),
                  size: Size.infinite,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: stage.height * 0.05,
                  child: Center(
                    child: Text('Trace the A', style: AppText.title),
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

class _TracePainter extends CustomPainter {
  _TracePainter(this.waypoints, this.reached);
  final List<Offset> waypoints;
  final int reached;

  @override
  void paint(Canvas canvas, Size size) {
    Offset px(Offset f) => Offset(f.dx * size.width, f.dy * size.height);
    // Dotted guide (whole path).
    final guide = Paint()
      ..color = AppColors.accentTint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    _drawStrokes(canvas, px, guide);
    // Traced portion so far (accent).
    final done = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i < reached; i++) {
      // skip the "pen up" jump back to the apex between strokes.
      if (i == 3) continue;
      canvas.drawLine(px(waypoints[i - 1]), px(waypoints[i]), done);
    }
    // Waypoint dots.
    for (int i = 0; i < waypoints.length; i++) {
      final p = Paint()
        ..color = i < reached ? AppColors.accent : AppColors.textTertiary;
      canvas.drawCircle(px(waypoints[i]), 8, p);
    }
    // Next target pulse.
    if (reached < waypoints.length) {
      final p = Paint()
        ..color = AppColors.support
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(px(waypoints[reached]), 22, p);
    }
  }

  void _drawStrokes(Canvas canvas, Offset Function(Offset) px, Paint paint) {
    // Left diagonal, right diagonal, cross-bar.
    canvas.drawLine(px(waypoints[0]), px(waypoints[2]), paint);
    canvas.drawLine(px(waypoints[3]), px(waypoints[5]), paint);
    canvas.drawLine(px(waypoints[6]), px(waypoints[7]), paint);
  }

  @override
  bool shouldRepaint(covariant _TracePainter old) => old.reached != reached;
}

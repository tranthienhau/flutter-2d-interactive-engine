import 'package:flutter/material.dart';

import '../core/responsive/stage.dart';
import '../theme/app_theme.dart';
import 'mechanic.dart';

/// Template 4 - Mask Reveal. A scratch-off grid covers a hidden picture; drag
/// to clear cells. Solved when enough of the mask is scratched away.
class MaskRevealMechanic extends MechanicWidget {
  const MaskRevealMechanic({super.key, required super.ctx});

  @override
  State<MaskRevealMechanic> createState() => _MaskRevealMechanicState();
}

class _MaskRevealMechanicState extends State<MaskRevealMechanic> {
  static const _cols = 8, _rows = 12;
  final Set<int> _cleared = {};
  bool _done = false;

  void _scratchAt(Offset localFrac) {
    final col = (localFrac.dx * _cols).floor().clamp(0, _cols - 1);
    final row = (localFrac.dy * _rows).floor().clamp(0, _rows - 1);
    final idx = row * _cols + col;
    if (_cleared.add(idx)) {
      setState(() {});
      widget.ctx.audio.playSfx('scratch');
      if (_cleared.length / (_cols * _rows) > 0.7 && !_done) {
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
        return GestureDetector(
          onPanUpdate: (d) {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(d.globalPosition);
            _scratchAt(Offset(local.dx / stage.width, local.dy / stage.height));
          },
          onPanStart: (d) {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(d.globalPosition);
            _scratchAt(Offset(local.dx / stage.width, local.dy / stage.height));
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hidden picture underneath.
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFE39A), Color(0xFFFFB020)],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.pets,
                      size: stage.minSide * 0.4, color: Colors.white),
                ),
              ),
              // Scratch mask on top.
              CustomPaint(
                painter: _MaskPainter(_cleared, _cols, _rows),
                size: Size.infinite,
              ),
              Positioned(
                left: 0,
                right: 0,
                top: stage.height * 0.04,
                child: Center(
                  child: Text('Scratch to reveal!',
                      style: AppText.title.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MaskPainter extends CustomPainter {
  _MaskPainter(this.cleared, this.cols, this.rows);
  final Set<int> cleared;
  final int cols, rows;

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / cols, ch = size.height / rows;
    final p = Paint()..color = AppColors.accentTint;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (cleared.contains(r * cols + c)) continue;
        canvas.drawRect(
          Rect.fromLTWH(c * cw, r * ch, cw + 0.5, ch + 0.5),
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MaskPainter old) =>
      old.cleared.length != cleared.length;
}

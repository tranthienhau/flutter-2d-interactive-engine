import 'package:flutter/material.dart';

import '../core/responsive/stage.dart';
import '../theme/app_theme.dart';
import 'mechanic.dart';

/// Template 3 - Analog Slider. Drag to set a continuous value; solved when the
/// value lands inside a target band (fill the cup roughly halfway).
class AnalogSliderMechanic extends MechanicWidget {
  const AnalogSliderMechanic({super.key, required super.ctx});

  @override
  State<AnalogSliderMechanic> createState() => _AnalogSliderMechanicState();
}

class _AnalogSliderMechanicState extends State<AnalogSliderMechanic> {
  double _value = 0.05; // 0..1 fill
  bool _done = false;
  static const _lo = 0.4, _hi = 0.6;

  void _check() {
    if (!_done && _value >= _lo && _value <= _hi) {
      _done = true;
      widget.ctx.audio.playSfx('success');
      Future.delayed(const Duration(milliseconds: 600),
          () => widget.ctx.onSolved(3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StageBuilder(
      builder: (context, stage) {
        final cupW = stage.square(0.42);
        final cupH = stage.height * 0.42;
        return Container(
          color: AppColors.background,
          child: Stack(
            children: [
              // The cup, centred, filling from the bottom.
              StageBox(
                stage: stage,
                left: 0.5,
                top: 0.4,
                square: 0.5,
                align: Alignment.center,
                child: SizedBox(
                  width: cupW,
                  height: cupH,
                  child: CustomPaint(
                    painter: _CupPainter(_value, inBand: _value >= _lo && _value <= _hi),
                  ),
                ),
              ),
              // Vertical slider on the right controls the fill.
              Positioned(
                right: stage.width * 0.12,
                top: stage.height * 0.2,
                bottom: stage.height * 0.2,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    width: stage.height * 0.6,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 12,
                        activeTrackColor: AppColors.accent,
                        inactiveTrackColor: AppColors.accentTint,
                        thumbColor: AppColors.accent,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                      ),
                      child: Slider(
                        value: _value,
                        onChanged: (v) {
                          setState(() => _value = v);
                          widget.ctx.audio.playSfx('tick');
                        },
                        onChangeEnd: (_) => _check(),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: stage.height * 0.08,
                child: Center(
                  child: Text('Fill to the line',
                      style: AppText.title),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CupPainter extends CustomPainter {
  _CupPainter(this.fill, {required this.inBand});
  final double fill;
  final bool inBand;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.15, h * 0.05, w * 0.7, h * 0.9),
      bottomLeft: const Radius.circular(30),
      bottomRight: const Radius.circular(30),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    );
    // Liquid
    canvas.save();
    canvas.clipRRect(body);
    final liquidTop = h * 0.95 - (h * 0.9) * fill;
    final liq = Paint()..color = inBand ? AppColors.success : AppColors.accent;
    canvas.drawRect(Rect.fromLTRB(0, liquidTop, w, h), liq);
    canvas.restore();
    // Cup outline
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = AppColors.textPrimary.withValues(alpha: 0.7);
    canvas.drawRRect(body, outline);
    // Target line at the halfway band centre.
    final target = h * 0.95 - (h * 0.9) * 0.5;
    final tp = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 4;
    canvas.drawLine(Offset(w * 0.1, target), Offset(w * 0.9, target), tp);
  }

  @override
  bool shouldRepaint(covariant _CupPainter old) =>
      old.fill != fill || old.inBand != inBand;
}

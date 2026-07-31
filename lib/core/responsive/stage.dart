import 'package:flutter/widgets.dart';

/// Dynamic Coordinate Scaling.
///
/// The whole interactive surface is authored in a *virtual, resolution-
/// independent* coordinate space. Every hitbox, target and token is placed
/// with relative fractions (0..1) of the stage, so a mechanic authored once
/// renders identically on a 4:3 tablet and a 19.5:9 phone without clipping or
/// off-screen drift.
///
/// [Stage] resolves the current pixel size once per layout; [StagePos] and
/// [StageRect] convert fractions to pixels; [StageBox] positions a child.
class Stage {
  const Stage(this.size);

  /// Physical pixel size of the interactive area for this frame.
  final Size size;

  double get width => size.width;
  double get height => size.height;

  /// Shortest side - use it to size things that must stay circular / square
  /// (a token should be the same visual size regardless of aspect ratio).
  double get minSide => size.shortestSide;

  /// Fraction (0..1) -> pixels on each axis.
  Offset px(double fx, double fy) => Offset(fx * width, fy * height);

  /// A relative rect [0..1] -> a pixel rect.
  Rect rect(double fx, double fy, double fw, double fh) =>
      Rect.fromLTWH(fx * width, fy * height, fw * width, fh * height);

  /// A size expressed as a fraction of [minSide] - keeps tokens square across
  /// aspect ratios (a 0.18 token is 18% of the short edge everywhere).
  double square(double fraction) => minSide * fraction;

  /// Point-in-rect hit test in fractional space (used by mechanics to decide
  /// whether a dragged token landed inside a target).
  bool hit(Offset pointPx, Rect targetPx) => targetPx.contains(pointPx);
}

/// Builds a [Stage] from the incoming constraints and hands it to [builder].
/// This is the single entry point every mechanic uses so scaling is uniform.
class StageBuilder extends StatelessWidget {
  const StageBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, Stage stage) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        );
        return builder(context, Stage(size));
      },
    );
  }
}

/// Positions [child] at a fractional top-left with a fractional/relative size.
/// `wFraction`/`hFraction` are fractions of the stage; if [square] is set the
/// child is sized from the stage's short side instead (keeps it circular).
class StageBox extends StatelessWidget {
  const StageBox({
    super.key,
    required this.stage,
    required this.left,
    required this.top,
    this.wFraction,
    this.hFraction,
    this.square,
    this.align = Alignment.topLeft,
    required this.child,
  });

  final Stage stage;
  final double left;
  final double top;
  final double? wFraction;
  final double? hFraction;
  final double? square;
  final Alignment align;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final w = square != null ? stage.square(square!) : (wFraction ?? 0) * stage.width;
    final h = square != null ? stage.square(square!) : (hFraction ?? 0) * stage.height;
    // Anchor by alignment so `align: center` treats (left,top) as the centre.
    final dx = left * stage.width - w * ((align.x + 1) / 2);
    final dy = top * stage.height - h * ((align.y + 1) / 2);
    return Positioned(
      left: dx,
      top: dy,
      width: w,
      height: h,
      child: child,
    );
  }
}

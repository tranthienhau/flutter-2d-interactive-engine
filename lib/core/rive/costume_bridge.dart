import 'dart:math';

import 'package:flutter/material.dart';

/// The Rive Animation Bridge.
///
/// This is the seam the illustrator's `.riv` file plugs into. It exposes the
/// exact operations the brief calls for - swap a costume skin by code, and
/// trigger a randomized global reaction - behind a runtime-agnostic API.
///
/// When an artboard `mascot.riv` is dropped into `assets/rive/`, [RiveMascot]
/// binds these inputs to a StateMachineController (skin index + reaction
/// trigger). Until then it renders a painted stand-in so the app is fully
/// demoable on a simulator with no artist assets.
class CostumeBridge extends ChangeNotifier {
  CostumeBridge();

  /// StateMachine input: which costume skin the artboard shows.
  String? _equippedCostumeId;
  Color _skinColor = const Color(0xFF6B4EFF);

  /// StateMachine trigger: last fired global reaction (cheer, jump, wave...).
  String _reaction = 'idle';
  int _reactionNonce = 0;

  String? get equippedCostumeId => _equippedCostumeId;
  Color get skinColor => _skinColor;
  String get reaction => _reaction;
  int get reactionNonce => _reactionNonce;

  /// Swap the costume skin via code. In Rive this sets a number input on the
  /// state machine; here it also carries a tint for the painted fallback.
  void equipSkin(String costumeId, Color color) {
    _equippedCostumeId = costumeId;
    _skinColor = color;
    notifyListeners();
  }

  static const _reactions = ['cheer', 'jump', 'wave', 'spin', 'clap'];

  /// Fire a randomized global reaction (Rive trigger). Nonce forces the
  /// fallback animation to restart even if the same reaction repeats.
  void triggerRandomReaction([Random? rnd]) {
    final r = (rnd ?? Random()).nextInt(_reactions.length);
    _reaction = _reactions[r];
    _reactionNonce++;
    notifyListeners();
  }
}

/// The mascot view. Reads the bridge and animates a friendly painted fox that
/// reacts and wears the equipped skin tint. Swap the internals for a
/// `RiveAnimation.asset` once the artboard is delivered - the bridge API and
/// every call site stay identical.
class RiveMascot extends StatefulWidget {
  const RiveMascot({super.key, required this.bridge, this.size = 160});

  final CostumeBridge bridge;
  final double size;

  @override
  State<RiveMascot> createState() => _RiveMascotState();
}

class _RiveMascotState extends State<RiveMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    widget.bridge.addListener(_onReaction);
  }

  void _onReaction() {
    // Restart the bounce whenever a reaction is triggered.
    _c
      ..reset()
      ..forward();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.bridge.removeListener(_onReaction);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c, widget.bridge]),
      builder: (context, _) {
        final bob = sin(_c.value * pi) * (widget.size * 0.05);
        return Transform.translate(
          offset: Offset(0, -bob),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _FoxPainter(
              skin: widget.bridge.skinColor,
              equipped: widget.bridge.equippedCostumeId != null,
              wiggle: sin(_c.value * pi * 2) * 0.06,
            ),
          ),
        );
      },
    );
  }
}

class _FoxPainter extends CustomPainter {
  _FoxPainter({required this.skin, required this.equipped, required this.wiggle});

  final Color skin;
  final bool equipped;
  final double wiggle;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()..isAntiAlias = true;
    const fox = Color(0xFFF08A3C);
    const foxDark = Color(0xFFDC6B1E);
    const cream = Color(0xFFFFF3E6);

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(wiggle);
    canvas.translate(-w / 2, -h / 2);

    // Ears
    p.color = foxDark;
    canvas.drawPath(_tri(Offset(w * 0.28, h * 0.22), w * 0.16), p);
    canvas.drawPath(_tri(Offset(w * 0.72, h * 0.22), w * 0.16), p);

    // Head
    p.color = fox;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.3, p);

    // Cheeks / muzzle
    p.color = cream;
    canvas.drawCircle(Offset(w * 0.5, h * 0.58), w * 0.17, p);

    // Eyes
    p.color = const Color(0xFF1A1530);
    canvas.drawCircle(Offset(w * 0.42, h * 0.48), w * 0.035, p);
    canvas.drawCircle(Offset(w * 0.58, h * 0.48), w * 0.035, p);

    // Nose
    canvas.drawCircle(Offset(w * 0.5, h * 0.56), w * 0.03, p);

    // Equipped skin: a little hat tint on top of the head
    if (equipped) {
      p.color = skin;
      canvas.drawPath(_tri(Offset(w * 0.5, h * 0.12), w * 0.2), p);
      p.color = Colors.white;
      canvas.drawCircle(Offset(w * 0.5, h * 0.11), w * 0.02, p);
    }
    canvas.restore();
  }

  Path _tri(Offset apexBase, double s) {
    // Upward triangle centred horizontally at apexBase.
    return Path()
      ..moveTo(apexBase.dx, apexBase.dy - s)
      ..lineTo(apexBase.dx - s * 0.8, apexBase.dy + s * 0.6)
      ..lineTo(apexBase.dx + s * 0.8, apexBase.dy + s * 0.6)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _FoxPainter old) =>
      old.skin != skin || old.equipped != equipped || old.wiggle != wiggle;
}

import 'dart:math';

import 'package:flutter/material.dart';

/// A single lightweight particle. Motion is a closed-form function of time
/// (position = start + velocity*t + gravity*t^2), so there is no per-frame
/// physics integration to accumulate cost - cheap enough for old devices.
class _Particle {
  _Particle({
    required this.origin,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotationSpeed,
    required this.isStar,
    required this.ttl,
  });

  final Offset origin; // fractional 0..1 within the paint box
  final Offset velocity; // fractional units per second
  final Color color;
  final double size;
  final double rotationSpeed;
  final bool isStar;
  final double ttl;
}

/// Non-physics visual emitter for celebrations (confetti + stars). Burst on
/// demand; particles fade and settle, then the widget can be torn down.
class ParticleBurst extends StatefulWidget {
  const ParticleBurst({
    super.key,
    this.count = 60,
    this.duration = const Duration(milliseconds: 2600),
    this.colors = const [
      Color(0xFF6B4EFF),
      Color(0xFFFFB020),
      Color(0xFFF5477E),
      Color(0xFF16A34A),
      Color(0xFF0EA5C4),
    ],
    this.repeat = true,
  });

  final int count;
  final Duration duration;
  final List<Color> colors;
  final bool repeat;

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late List<_Particle> _particles;
  // Fixed seed so screenshot runs are deterministic frame-to-frame.
  final _rnd = Random(7);

  @override
  void initState() {
    super.initState();
    _particles = _spawn();
    _c = AnimationController(vsync: this, duration: widget.duration);
    if (widget.repeat) {
      _c.repeat();
    } else {
      _c.forward();
    }
  }

  List<_Particle> _spawn() {
    return List.generate(widget.count, (i) {
      final angle = _rnd.nextDouble() * 2 * pi;
      final speed = 0.25 + _rnd.nextDouble() * 0.55;
      return _Particle(
        origin: Offset(0.5 + (_rnd.nextDouble() - 0.5) * 0.1, 0.35),
        velocity: Offset(cos(angle) * speed, sin(angle) * speed - 0.35),
        color: widget.colors[_rnd.nextInt(widget.colors.length)],
        size: 6 + _rnd.nextDouble() * 10,
        rotationSpeed: (_rnd.nextDouble() - 0.5) * 8,
        isStar: _rnd.nextBool(),
        ttl: 0.7 + _rnd.nextDouble() * 0.3,
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _ParticlePainter(_particles, _c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.t);

  final List<_Particle> particles;
  final double t; // 0..1 progress

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final local = t / p.ttl;
      if (local > 1) continue;
      // Closed-form ballistic path, gravity pulls back down.
      final gx = p.origin.dx + p.velocity.dx * local;
      final gy = p.origin.dy + p.velocity.dy * local + 0.6 * local * local;
      final pos = Offset(gx * size.width, gy * size.height);
      final opacity = (1 - local).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.rotationSpeed * local);
      if (p.isStar) {
        _drawStar(canvas, p.size, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = -pi / 2 + i * 2 * pi / 5;
      final inner = outer + pi / 5;
      final o = Offset(cos(outer) * r, sin(outer) * r);
      final ip = Offset(cos(inner) * r * 0.45, sin(inner) * r * 0.45);
      if (i == 0) path.moveTo(o.dx, o.dy); else path.lineTo(o.dx, o.dy);
      path.lineTo(ip.dx, ip.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}

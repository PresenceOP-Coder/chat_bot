import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class Particle {
  Offset position;
  Offset velocity;
  double radius;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
  });
}

class InteractiveBackground extends StatefulWidget {
  const InteractiveBackground({super.key});

  @override
  State<InteractiveBackground> createState() => _InteractiveBackgroundState();
}

class _InteractiveBackgroundState extends State<InteractiveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  Offset? _mousePosition;
  final int _particleCount = 55;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initParticles(Size size) {
    if (_particles.isNotEmpty) return;
    final colors = [
      AppTheme.cyanAccent,
      AppTheme.purpleAccent,
      Colors.white,
    ];
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        Particle(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 1.0,
            (_random.nextDouble() - 0.5) * 1.0,
          ),
          radius: _random.nextDouble() * 2 + 1.5,
          color: colors[_random.nextInt(colors.length)],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initParticles(size);

        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.5, -0.5),
              radius: 1.4,
              colors: [
                Color(0xFF141328),
                AppTheme.backgroundColor,
              ],
            ),
          ),
          child: MouseRegion(
            onHover: (event) {
              setState(() {
                _mousePosition = event.localPosition;
              });
            },
            onExit: (event) {
              setState(() {
                _mousePosition = null;
              });
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: ParticlePainter(
                    particles: _particles,
                    mousePosition: _mousePosition,
                    random: _random,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Offset? mousePosition;
  final math.Random random;

  ParticlePainter({
    required this.particles,
    required this.mousePosition,
    required this.random,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Faint overlay ambient glows
    final glowPaint1 = Paint()
      ..color = AppTheme.cyanAccent.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 200, glowPaint1);

    final glowPaint2 = Paint()
      ..color = AppTheme.purpleAccent.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 250, glowPaint2);

    for (var particle in particles) {
      particle.position += particle.velocity;

      if (particle.position.dx < 0) particle.position = Offset(size.width, particle.position.dy);
      if (particle.position.dx > size.width) particle.position = Offset(0, particle.position.dy);
      if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, size.height);
      if (particle.position.dy > size.height) particle.position = Offset(particle.position.dx, 0);

      // Draw blurred glow ring behind particle
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(particle.position, particle.radius * 2.5, glowPaint);

      // Draw solid inner particle
      final solidPaint = Paint()
        ..color = particle.color.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(particle.position, particle.radius, solidPaint);

      if (mousePosition != null) {
        final dist = (particle.position - mousePosition!).distance;
        if (dist < 180) {
          final opacity = (1.0 - (dist / 180)).clamp(0.0, 1.0) * 0.75;
          final linePaint = Paint()
            ..shader = LinearGradient(
              colors: [
                AppTheme.cyanAccent.withValues(alpha: opacity),
                AppTheme.purpleAccent.withValues(alpha: opacity),
              ],
            ).createShader(Rect.fromPoints(particle.position, mousePosition!))
            ..strokeWidth = 1.6;
          canvas.drawLine(particle.position, mousePosition!, linePaint);
        }
      }

      for (var other in particles) {
        if (other == particle) continue;
        final dist = (particle.position - other.position).distance;
        if (dist < 100) {
          final opacity = (1.0 - (dist / 100)).clamp(0.0, 1.0) * 0.08;
          final linePaint = Paint()
            ..color = Colors.white.withValues(alpha: opacity)
            ..strokeWidth = 0.5;
          canvas.drawLine(particle.position, other.position, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

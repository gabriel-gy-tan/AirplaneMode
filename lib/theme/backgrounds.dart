import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shapes.dart';

/// Full-screen painted background for each theme.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    return IgnorePointer(
      child: isAero
          ? const _AeroBackground()
          : isPhantom
              ? const _PhantomBackground()
              : const _P3Background(),
    );
  }
}

class _P3Background extends StatelessWidget {
  const _P3Background();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _P3BackgroundPainter(Theme.of(context).scaffoldBackgroundColor),
      size: Size.infinite,
    );
  }
}

class _P3BackgroundPainter extends CustomPainter {
  _P3BackgroundPainter(this.base);

  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [base, const Color(0xFF0C2243), base],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );

    // Diagonal light shards, very subtle.
    final shardPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          P3Palette.primary.withValues(alpha: 0.12),
          P3Palette.primary.withValues(alpha: 0),
        ],
      ).createShader(rect);
    final shardPath = Path();
    shardPath.moveTo(size.width * 0.1, 0);
    shardPath.lineTo(size.width * 0.38, 0);
    shardPath.lineTo(size.width * 0.02, size.height);
    shardPath.lineTo(-size.width * 0.26, size.height);
    shardPath.close();
    canvas.drawPath(shardPath, shardPaint);

    final shard2 = Path()
      ..moveTo(size.width * 0.72, 0)
      ..lineTo(size.width * 0.86, 0)
      ..lineTo(size.width * 0.58, size.height)
      ..lineTo(size.width * 0.44, size.height)
      ..close();
    canvas.drawPath(
      shard2,
      Paint()
        ..shader = LinearGradient(
          colors: [
            P3Palette.yellow.withValues(alpha: 0.06),
            P3Palette.yellow.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );

    // Night city skyline silhouette along the bottom.
    final skyline = Paint()..color = const Color(0xFF040A16);
    final rng = math.Random(7);
    double x = -10;
    while (x < size.width + 10) {
      final w = 18.0 + rng.nextDouble() * 42;
      final h = 26.0 + rng.nextDouble() * size.height * 0.10;
      final y = size.height - h;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), skyline);
      // sparse lit windows
      final windowPaint = Paint()..color = P3Palette.primary.withValues(alpha: 0.5);
      for (var i = 0; i < 3; i++) {
        if (rng.nextDouble() > 0.55) {
          canvas.drawRect(
            Rect.fromLTWH(x + 4 + rng.nextDouble() * (w - 8), y + 6 + rng.nextDouble() * (h - 12), 2.5, 2.5),
            windowPaint,
          );
        }
      }
      x += w + rng.nextDouble() * 8;
    }

    // Horizon glow.
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 90, size.width, 90),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            P3Palette.primary.withValues(alpha: 0.10),
          ],
        ).createShader(Rect.fromLTWH(0, size.height - 90, size.width, 90)),
    );
  }

  @override
  bool shouldRepaint(covariant _P3BackgroundPainter old) => old.base != base;
}

class _PhantomBackground extends StatelessWidget {
  const _PhantomBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PhantomBackgroundPainter(), size: Size.infinite);
  }
}

/// Flat graphic composition: dark plates, one wide diagonal band,
/// electric-blue slashes and a short yellow accent — no glow, no blur.
class _PhantomBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = PhantomPalette.bg);

    // Wide mid-screen diagonal band (quiet midnight plate).
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.58)
        ..lineTo(w, h * 0.38)
        ..lineTo(w, h * 0.60)
        ..lineTo(0, h * 0.80)
        ..close(),
      Paint()..color = PhantomPalette.surface,
    );

    // Two parallel electric-blue slashes falling to the left.
    void slash(double xTop, double thickness, Color color) {
      canvas.drawPath(
        Path()
          ..moveTo(xTop, 0)
          ..lineTo(xTop + thickness, 0)
          ..lineTo(xTop + thickness - w * 0.30, h)
          ..lineTo(xTop - w * 0.30, h)
          ..close(),
        Paint()..color = color,
      );
    }

    slash(w * 0.60, w * 0.10, PhantomPalette.blue.withValues(alpha: 0.16));
    slash(w * 0.74, w * 0.03, PhantomPalette.blue.withValues(alpha: 0.12));

    // Short yellow accent slash, upper-left, cropped by the edge.
    canvas.drawPath(
      Path()
        ..moveTo(-w * 0.02, h * 0.045)
        ..lineTo(w * 0.16, h * 0.045)
        ..lineTo(w * 0.10, h * 0.16)
        ..lineTo(-w * 0.08, h * 0.16)
        ..close(),
      Paint()..color = PhantomPalette.yellow.withValues(alpha: 0.10),
    );

    // Faint technical hairlines.
    final line = Paint()..color = Colors.white.withValues(alpha: 0.05);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.24, w, 1), line);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.88, w, 1), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AeroBackground extends StatelessWidget {
  const _AeroBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AeroBackgroundPainter(), size: Size.infinite);
  }
}

class _AeroBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AeroPalette.skyTop, Color(0xFF8FD0FF), AeroPalette.skyBottom],
          stops: [0, 0.55, 1],
        ).createShader(rect),
    );

    // Sun glow top-right.
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08), size.width * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(
            center: Offset(size.width * 0.85, size.height * 0.08),
            radius: size.width * 0.45)),
    );

    // A few quiet bubble accents — kept sparse so covers and text stay focus.
    final rng = math.Random(3);
    for (var i = 0; i < 5; i++) {
      final c = Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height * 0.7);
      final r = 8.0 + rng.nextDouble() * 18;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(
        c.translate(r * 0.25, -r * 0.25),
        r * 0.26,
        Paint()..color = Colors.white.withValues(alpha: 0.45),
      );
    }

    // Soft clouds.
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.55);
    void drawCloud(double x, double y, double s) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 120 * s, height: 36 * s), cloud);
      canvas.drawOval(Rect.fromCenter(center: Offset(x - 34 * s, y + 6 * s), width: 70 * s, height: 28 * s), cloud);
      canvas.drawOval(Rect.fromCenter(center: Offset(x + 36 * s, y + 8 * s), width: 80 * s, height: 26 * s), cloud);
    }

    drawCloud(size.width * 0.18, size.height * 0.12, 1.0);
    drawCloud(size.width * 0.7, size.height * 0.28, 0.8);
    drawCloud(size.width * 0.35, size.height * 0.45, 0.6);

    // Green hill along the bottom.
    final hill = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.86, size.width * 0.55, size.height * 0.93)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.99, size.width, size.height * 0.88)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AeroPalette.green.withValues(alpha: 0.85), const Color(0xFF1F9D4D)],
        ).createShader(Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2)),
    );
    canvas.drawPath(
      hill,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.25), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, size.height * 0.85, size.width, size.height * 0.15)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Themed panel used across screens.
///
/// Persona: cut-corner HUD panel with a hard-edged offset shadow.
/// Aero: vertical blue gloss with bright top edge and soft drop shadow.
class ThemedPanel extends StatelessWidget {
  const ThemedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.align,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final AlignmentGeometry? align;

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final decoration = isAero
        ? AeroPalette.panelDecoration(radius: borderRadius)
        : isPhantom
            ? ShapeDecoration(
                color: PhantomPalette.surface.withValues(alpha: 0.96),
                shadows: [
                  BoxShadow(
                    color: PhantomPalette.blue.withValues(alpha: 0.40),
                    offset: const Offset(4, 4),
                  ),
                ],
                shape: CutCornerBorder(
                  radius: borderRadius?.topLeft.x ?? 10,
                  diagonal: true,
                  side: const BorderSide(color: PhantomPalette.hairline),
                ),
              )
            : ShapeDecoration(
                color: P3Palette.surface.withValues(alpha: 0.94),
                shadows: const [
                  BoxShadow(
                    color: Color(0xCC03070F),
                    offset: Offset(3, 3),
                  ),
                ],
                shape: CutCornerBorder(
                  radius: borderRadius?.topLeft.x ?? 8,
                  diagonal: true,
                  side: const BorderSide(color: P3Palette.outline),
                ),
              );
    return Container(
      alignment: align,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}

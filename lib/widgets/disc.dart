import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_controller.dart';
import '../theme/app_theme.dart';

/// A vinyl-style disc with the artwork label; spins while [spinning].
class VinylDisc extends StatefulWidget {
  const VinylDisc({
    super.key,
    required this.size,
    this.artwork,
    this.spinning = false,
    this.showGloss = true,
    this.emphasis = false,
  });

  final double size;
  final Uint8List? artwork;
  final bool spinning;
  final bool showGloss;

  /// Boosts the accent ring so the selected disc stands out.
  final bool emphasis;

  @override
  State<VinylDisc> createState() => _VinylDiscState();
}

class _VinylDiscState extends State<VinylDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didUpdateWidget(VinylDisc old) {
    super.didUpdateWidget(old);
    _syncSpin();
  }

  @override
  void initState() {
    super.initState();
    _syncSpin();
  }

  void _syncSpin() {
    final reduce = context.read<SettingsController>().reduceMotion;
    if (widget.spinning && !reduce) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final size = widget.size;
    final emphasis = widget.emphasis;
    final accentYellow =
        isPhantom ? PhantomPalette.yellow : P3Palette.yellow;
    final accentBlue = isPhantom ? PhantomPalette.blue : P3Palette.primary;
    final ringColor = isAero
        ? Colors.white
        : (emphasis ? accentYellow : accentBlue);
    final ringWidth = size * 0.008 * (emphasis ? 1.9 : 1);
    final ringAlpha = emphasis ? 1.0 : (isAero ? 0.55 : 0.35);

    return AnimatedBuilder(
      animation: _spin,
      builder: (context, _) {
        return Transform.rotate(
          angle: _spin.value * 6.28318,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vinyl base with grooves.
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF1A1A1E), Color(0xFF0B0B0D)],
                      radius: 0.95,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isAero ? 0.35 : 0.55),
                        blurRadius: size * 0.06,
                        offset: Offset(0, size * 0.02),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _GroovePainter(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                // Outer accent ring.
                Container(
                  width: size - ringWidth,
                  height: size - ringWidth,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor.withValues(alpha: ringAlpha),
                      width: ringWidth,
                    ),
                  ),
                ),
                // Artwork label.
                ClipOval(
                  child: Container(
                    width: size * 0.62,
                    height: size * 0.62,
                    color: isAero
                        ? AeroPalette.skyTop
                        : isPhantom
                            ? PhantomPalette.surface
                            : P3Palette.surfaceAlt,
                    child: widget.artwork != null
                        ? Image.memory(
                            widget.artwork!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, _, _) =>
                                const _DiscPlaceholder(),
                          )
                        : const _DiscPlaceholder(),
                  ),
                ),
                // Thin ring framing the label.
                Container(
                  width: size * 0.635,
                  height: size * 0.635,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                      border: Border.all(
                        color: isAero
                            ? Colors.white
                            : accentYellow,
                        width: size * 0.006,
                      ),
                  ),
                ),
                // Center hole.
                Container(
                  width: size * 0.055,
                  height: size * 0.055,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAero
                        ? Colors.white
                        : isPhantom
                            ? PhantomPalette.bg
                            : P3Palette.bg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (widget.showGloss)
                  Positioned.fill(
                    child: ClipOval(
                      child: Transform.rotate(
                        angle: 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: isAero ? 0.35 : 0.14),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.white.withValues(alpha: isAero ? 0.18 : 0.06),
                              ],
                              stops: const [0, 0.35, 0.65, 1],
                            ),
                          ),
                        ),
                      ),
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

class _DiscPlaceholder extends StatelessWidget {
  const _DiscPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    return Icon(
      Icons.album,
      size: 48,
      color: isAero
          ? Colors.white
          : isPhantom
              ? PhantomPalette.blue
              : P3Palette.primary,
    );
  }
}

class _GroovePainter extends CustomPainter {
  _GroovePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (double r = maxR * 0.36; r < maxR * 0.94; r += 3.5) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GroovePainter old) => old.color != color;
}

/// Spinning disc used as a loading indicator.
class DiscLoadingIndicator extends StatelessWidget {
  const DiscLoadingIndicator({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return VinylDisc(size: size, spinning: true, showGloss: false);
  }
}

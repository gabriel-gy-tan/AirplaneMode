import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../state/playback_controller.dart';
import '../theme/app_theme.dart';
import '../theme/shapes.dart';

class TransportControls extends StatelessWidget {
  const TransportControls({super.key, required this.playback});

  final PlaybackController playback;

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final accent = isAero
        ? AeroPalette.primary
        : isPhantom
            ? PhantomPalette.yellow
            : P3Palette.yellow;
    final onAccent = isAero
        ? Colors.white
        : isPhantom
            ? PhantomPalette.bg
            : P3Palette.bg;
    final idle = Theme.of(context).textTheme.bodyMedium?.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: playback.toggleShuffle,
          iconSize: 26,
          style: IconButton.styleFrom(
            foregroundColor: playback.shuffle ? accent : idle,
          ),
          icon: const Icon(Icons.shuffle),
          tooltip: 'Shuffle',
        ),
        const SizedBox(width: 8),
        _RoundControl(
          isAero: isAero,
          isPhantom: isPhantom,
          size: 52,
          iconSize: 34,
          enabled: playback.hasPrevious,
          icon: Icons.skip_previous,
          tooltip: 'Previous',
          onPressed: playback.previous,
        ),
        const SizedBox(width: 14),
        // Play / pause: signature accent button.
        _PlayButton(
          isAero: isAero,
          isPhantom: isPhantom,
          accent: accent,
          onAccent: onAccent,
          playing: playback.playing,
          onPressed: playback.playPause,
        ),
        const SizedBox(width: 14),
        _RoundControl(
          isAero: isAero,
          isPhantom: isPhantom,
          size: 52,
          iconSize: 34,
          enabled: playback.hasNext,
          icon: Icons.skip_next,
          tooltip: 'Next',
          onPressed: playback.next,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: playback.cycleRepeatMode,
          iconSize: 26,
          style: IconButton.styleFrom(
            foregroundColor:
                playback.repeatMode != LoopMode.off ? accent : idle,
          ),
          icon: Icon(playback.repeatMode == LoopMode.one
              ? Icons.repeat_one
              : Icons.repeat),
          tooltip: 'Repeat',
        ),
      ],
    );
  }
}

/// Prev/next: flat icon in Persona, tactile raised disc in Aero,
/// cut-corner plate in Phantom.
class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.isAero,
    required this.isPhantom,
    required this.size,
    required this.iconSize,
    required this.enabled,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final bool isAero;
  final bool isPhantom;
  final double size;
  final double iconSize;
  final bool enabled;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? (isAero
            ? AeroPalette.textPrimary
            : isPhantom
                ? PhantomPalette.text
                : P3Palette.textPrimary)
        : Theme.of(context)
            .textTheme
            .bodyMedium
            ?.color
            ?.withValues(alpha: 0.35);

    if (isPhantom) {
      const shape = CutCornerBorder(
        radius: 9,
        diagonal: true,
        side: BorderSide.none,
      );
      return Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            width: size,
            height: size,
            decoration: ShapeDecoration(
              color: enabled ? PhantomPalette.surface : PhantomPalette.ink,
              shadows: const [
                BoxShadow(color: PhantomPalette.ink, offset: Offset(3, 3)),
              ],
              shape: const CutCornerBorder(
                radius: 9,
                diagonal: true,
                side: BorderSide(color: PhantomPalette.hairline),
              ),
            ),
            child: InkWell(
              customBorder: shape,
              onTap: enabled ? onPressed : null,
              child: Icon(icon, size: iconSize, color: color),
            ),
          ),
        ),
      );
    }
    if (!isAero) {
      return SizedBox(
        width: size,
        height: size,
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          iconSize: iconSize,
          style: IconButton.styleFrom(foregroundColor: color),
          icon: Icon(icon),
          tooltip: tooltip,
        ),
      );
    }
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFE4F6FF)],
            ),
            border: Border.all(color: AeroPalette.outline),
            boxShadow: [
              BoxShadow(
                color: AeroPalette.deep.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onPressed : null,
            child: Icon(icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }
}

/// Signature play/pause: angular yellow disc with hard shadow (Persona),
/// glossy dimensional button (Aero) or leaning yellow slab (Phantom).
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isAero,
    required this.isPhantom,
    required this.accent,
    required this.onAccent,
    required this.playing,
    required this.onPressed,
  });

  final bool isAero;
  final bool isPhantom;
  final Color accent;
  final Color onAccent;
  final bool playing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Icon(
      playing ? Icons.pause : Icons.play_arrow,
      size: isPhantom ? 40 : 42,
      color: onAccent,
    );
    if (isPhantom) {
      const slant = SlantBorder(slant: 13, side: BorderSide.none);
      return Material(
        color: Colors.transparent,
        child: Ink(
          width: 86,
          height: 64,
          decoration: ShapeDecoration(
            color: accent,
            shadows: const [
              BoxShadow(color: PhantomPalette.ink, offset: Offset(5, 5)),
            ],
            shape: const SlantBorder(
              slant: 13,
              side: BorderSide(color: PhantomPalette.ink, width: 1.5),
            ),
          ),
          child: InkWell(
            customBorder: slant,
            onTap: onPressed,
            child: Center(child: child),
          ),
        ),
      );
    }
    if (isAero) {
      return Material(
        color: Colors.transparent,
        child: Ink(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(accent, Colors.white, 0.5)!,
                accent,
                Color.lerp(accent, Colors.black, 0.2)!,
              ],
              stops: const [0, 0.45, 1],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.55),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(customBorder: const CircleBorder(), onTap: onPressed, child: Center(child: child)),
        ),
      );
    }
    // Persona: flat yellow with a hard offset shadow.
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: 72,
        height: 72,
        decoration: ShapeDecoration(
          color: accent,
          shadows: const [
            BoxShadow(color: Color(0xE6020509), offset: Offset(5, 5)),
          ],
          shape: const CircleBorder(
            side: BorderSide(color: Color(0xFF020509), width: 1.5),
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music_folder.dart';
import '../state/library_controller.dart';
import '../theme/app_theme.dart';
import '../theme/shapes.dart';

/// Deterministic non-cryptographic hash (FNV-1a) so a folder always
/// derives the same generated cover across rebuilds and app launches.
int stableHash(String value) {
  var h = 0x811c9dc5;
  for (final code in value.codeUnits) {
    h ^= code;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

/// Reusable CD jewel-case: plastic rim, spine, printed insert with
/// real folder artwork or a deterministic generated graphic cover.
class CdCase extends StatelessWidget {
  const CdCase({super.key, required this.folder, this.index});

  final MusicFolder folder;

  /// Position of this folder in the library (1-based), shown as a sticker.
  final int? index;

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final cover = folder.coverSong;
    final radius = BorderRadius.circular(isAero ? 8 : isPhantom ? 2 : 3);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isAero
            ? [
                BoxShadow(
                  color: const Color(0xFF12405F).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : isPhantom
                ? [
                    BoxShadow(
                      color: PhantomPalette.blue.withValues(alpha: 0.55),
                      offset: const Offset(5, 5),
                    ),
                  ]
                : const [
                    BoxShadow(color: Color(0xD9020509), offset: Offset(4, 4)),
                  ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          color: isAero
              ? Colors.white
              : isPhantom
                  ? PhantomPalette.ink
                  : P3Palette.steel,
          padding: const EdgeInsets.fromLTRB(7, 4, 4, 4),
          child: Row(
            children: [
              _Spine(width: 7),
              const SizedBox(width: 4),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Printed insert: real artwork or generated cover.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(isAero ? 4 : 1),
                      child: cover == null
                          ? GeneratedCover(name: folder.name)
                          : _ArtworkInsert(
                              songId: cover.id, fallbackName: folder.name),
                    ),
                    // Plastic gloss across the front lid.
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(
                                  alpha: isAero ? 0.35 : 0.16),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.white.withValues(
                                  alpha: isAero ? 0.14 : 0.05),
                            ],
                            stops: const [0, 0.32, 0.7, 1],
                          ),
                        ),
                      ),
                    ),
                    if (index != null)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: _IndexSticker(index: index!),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtworkInsert extends StatelessWidget {
  const _ArtworkInsert({required this.songId, required this.fallbackName});

  final int songId;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryController>();
    return FutureBuilder<Uint8List?>(
      future: library.artwork(songId),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          // Stable graphic cover while loading or when art is missing.
          return GeneratedCover(name: fallbackName);
        }
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => GeneratedCover(name: fallbackName),
        );
      },
    );
  }
}

class _Spine extends StatelessWidget {
  const _Spine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final base = isAero
        ? const Color(0xFFE9F8FF)
        : isPhantom
            ? PhantomPalette.surface
            : P3Palette.surfaceAlt;
    final line = isAero
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.22);
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(
                base,
                isAero
                    ? Colors.cyan.shade100
                    : isPhantom
                        ? PhantomPalette.ink
                        : Colors.black,
                0.25)!,
            base,
          ],
        ),
        border: Border(
          left: BorderSide(
              color: isAero
                  ? Colors.white
                  : Colors.black.withValues(alpha: 0.5)),
          right: BorderSide(
              color: isAero
                  ? AeroPalette.outline
                  : isPhantom
                      ? PhantomPalette.hairline
                      : P3Palette.outline.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _hinge(line),
          _hinge(line),
        ],
      ),
    );
  }

  Widget _hinge(Color color) => Container(height: 10, color: color);
}

class _IndexSticker extends StatelessWidget {
  const _IndexSticker({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final label = index.toString().padLeft(2, '0');
    if (isPhantom) {
      // Yellow parallelogram chip, ink text — the game-menu index sticker.
      return ClipPath(
        clipper: ShapeBorderClipper(
            shape: SlantBorder(slant: 5, side: BorderSide.none)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          color: PhantomPalette.yellow,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.4,
              color: PhantomPalette.bg,
            ),
          ),
        ),
      );
    }
    if (isAero) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE4F6FF)],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AeroPalette.outline),
          boxShadow: [
            BoxShadow(
              color: AeroPalette.deep.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontVariations: const [FontVariation('wght', 800)],
            fontSize: 11,
            color: AeroPalette.primary,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      color: P3Palette.yellow,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 1,
          color: P3Palette.bg,
        ),
      ),
    );
  }
}

/// Deterministic graphic cover rendered with Flutter widgets.
///
/// Same [name] always produces the same colours, stripe and label.
class GeneratedCover extends StatelessWidget {
  const GeneratedCover({super.key, required this.name});

  final String name;

  String get _initial {
    final trimmed = name.trim();
    for (final ch in trimmed.runes) {
      final c = String.fromCharCode(ch);
      if (RegExp(r'[A-Za-z]').hasMatch(c)) return c.toUpperCase();
      // Non-Latin scripts (CJK, Arabic, …) read fine as an initial.
      if (ch > 0x0250) return c;
    }
    if (trimmed.isEmpty) return '♪';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final hash = stableHash(name.isEmpty ? 'airplanemode' : name);
    final combo = hash % 4;
    final discNumber = (hash % 48) + 1;
    final flipStripe = ((hash >> 4) % 2) == 0;

    // Theme-specific colour combos (stable per folder name).
    final (bg, accent, ink) = isAero
        ? switch (combo) {
            0 => (const Color(0xFFD9F5FF), const Color(0xFF68C7EB), AeroPalette.deep),
            1 => (const Color(0xFFEAF9FF), const Color(0xFF167CB5), AeroPalette.deep),
            2 => (const Color(0xFFCFEFFB), const Color(0xFFFFFFFF), AeroPalette.deep),
            _ => (const Color(0xFFF4FCFF), const Color(0xFF167CB5), AeroPalette.deep),
          }
        : isPhantom
            ? switch (combo) {
                0 => (PhantomPalette.bg, PhantomPalette.yellow, PhantomPalette.text),
                1 => (PhantomPalette.surface, PhantomPalette.blue, PhantomPalette.text),
                2 => (PhantomPalette.bg, PhantomPalette.blue, PhantomPalette.yellow),
                _ => (PhantomPalette.surface, PhantomPalette.yellow, PhantomPalette.text),
              }
            : switch (combo) {
                0 => (P3Palette.bg, P3Palette.yellow, P3Palette.textPrimary),
                1 => (P3Palette.steel, P3Palette.yellow, P3Palette.textPrimary),
                2 => (P3Palette.bg, P3Palette.primary, P3Palette.textPrimary),
                _ => (const Color(0xFF0D2445), P3Palette.yellow, P3Palette.textPrimary),
              };

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        final initialSize = (h * 0.92).clamp(36.0, 240.0);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isAero
                  ? [Color.lerp(bg, Colors.white, 0.5)!, bg]
                  : isPhantom
                      ? [bg, bg]
                      : [Color.lerp(bg, Colors.white, 0.06)!, bg],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Diagonal accent stripe.
              Positioned(
                top: -h * 0.1,
                left: flipStripe ? -w * 0.2 : null,
                right: flipStripe ? null : -w * 0.2,
                child: Transform.rotate(
                  angle: flipStripe ? -0.5 : 0.5,
                  child: Container(
                    width: w * 0.34,
                    height: h * 1.35,
                    color: accent.withValues(
                        alpha: isAero ? 0.55 : 0.9),
                  ),
                ),
              ),
              // Oversized cropped initial.
              Positioned(
                left: -w * 0.06,
                bottom: -h * 0.18,
                child: Text(
                  _initial,
                  style: TextStyle(
                    fontFamily: isAero ? 'Nunito' : 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: initialSize,
                    height: 1,
                    color: ink.withValues(alpha: isAero ? 0.85 : 0.92),
                  ),
                ),
              ),
              // Technical metadata label.
              Positioned(
                top: 6,
                left: 7,
                child: Text(
                  'DISC ${discNumber.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontFamily: isAero ? 'Nunito' : 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1.6,
                    color: ink.withValues(alpha: 0.9),
                  ),
                ),
              ),
              // Folder name, printed on the insert (chip keeps it legible
              // over the oversized initial).
              Positioned(
                left: 5,
                right: 5,
                bottom: 4,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isAero
                          ? Colors.white.withValues(alpha: 0.8)
                          : isPhantom
                              ? const Color(0xE604060F)
                              : const Color(0xE608172C),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isPhantom
                            ? PhantomPalette.hairline
                            : ink.withValues(alpha: 0.35),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: isAero ? 'Nunito' : 'Rajdhani',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.4,
                        color: ink,
                      ),
                    ),
                  ),
                ),
              ),
              // Top gloss line for the printed sleeve.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1,
                child: ColoredBox(
                    color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/playback_controller.dart';
import '../theme/app_theme.dart';
import '../theme/shapes.dart';
import 'disc.dart';

/// Compact bar shown above the bottom of library screens while a song is loaded.
///
/// Persona: dark navy HUD with angular edges and a yellow progress line.
/// Aero: translucent portable-player casing with a top highlight.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackController>();
    final song = playback.currentSong;
    if (song == null) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    final duration = playback.duration ?? Duration.zero;
    final maxMs = duration.inMilliseconds.toDouble();
    final posMs = playback.position.inMilliseconds
        .clamp(0, maxMs > 0 ? maxMs : 0)
        .toDouble();
    final progress = maxMs > 0 ? (posMs / maxMs).clamp(0.0, 1.0) : 0.0;

    final content = Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: _MiniDisc(songId: song.id, spinning: playback.playing),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                song.title,
                style: text.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                song.artist,
                style: text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: playback.playPause,
          iconSize: 32,
          icon: Icon(playback.playing ? Icons.pause : Icons.play_arrow),
          color: isAero
              ? AeroPalette.primary
              : isPhantom
                  ? PhantomPalette.yellow
                  : P3Palette.yellow,
          tooltip: playback.playing ? 'Pause' : 'Play',
        ),
        IconButton(
          onPressed: playback.next,
          iconSize: 28,
          icon: const Icon(Icons.skip_next),
          tooltip: 'Next',
        ),
      ],
    );

    final track = Container(
      height: 3,
      width: double.infinity,
      color: isAero
          ? Colors.white.withValues(alpha: 0.8)
          : isPhantom
              ? PhantomPalette.surface
              : P3Palette.steel,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            color: isAero
                ? AeroPalette.primary
                : isPhantom
                    ? PhantomPalette.yellow
                    : P3Palette.yellow,
          ),
        ),
      ),
    );

    Widget bar;
    if (isAero) {
      bar = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AeroPalette.deep.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF0FFFFFF), Color(0xCCFFFFFF), Color(0xB3F0FBFF)],
            stops: [0, 0.3, 1],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top-edge highlight.
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 6, 6),
              child: content,
            ),
            track,
          ],
        ),
      );
    } else if (isPhantom) {
      // Phantom: near-black angular HUD with a leaning yellow accent
      // block and a hard electric-blue offset.
      const shape = CutCornerBorder(
        radius: 7,
        diagonal: true,
        side: BorderSide.none,
      );
      bar = ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Container(
          decoration: ShapeDecoration(
            color: PhantomPalette.ink.withValues(alpha: 0.97),
            shadows: [
              BoxShadow(
                color: PhantomPalette.blue.withValues(alpha: 0.5),
                offset: const Offset(4, 4),
              ),
            ],
            shape: const CutCornerBorder(
              radius: 7,
              diagonal: true,
              side: BorderSide(color: PhantomPalette.hairline),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Leaning yellow accent block.
                    SizedBox(
                      width: 15,
                      child: ClipPath(
                        clipper: ShapeBorderClipper(
                          shape: SlantBorder(
                            slant: 7,
                            side: BorderSide.none,
                          ),
                        ),
                        child: ColoredBox(
                          color: PhantomPalette.yellow,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 6, 6),
                        child: content,
                      ),
                    ),
                  ],
                ),
              ),
              track,
            ],
          ),
        ),
      );
    } else {
      final shape = CutCornerBorder(radius: 8, diagonal: true, side: BorderSide.none);
      bar = ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Container(
          decoration: ShapeDecoration(
            color: P3Palette.surface.withValues(alpha: 0.96),
            shadows: const [
              BoxShadow(color: Color(0xE6020509), offset: Offset(3, 3)),
            ],
            shape: CutCornerBorder(
              radius: 8,
              diagonal: true,
              side: const BorderSide(color: P3Palette.outline),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yellow HUD accent along the left edge.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: P3Palette.yellow),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 6, 6),
                        child: content,
                      ),
                    ),
                  ],
                ),
              ),
              track,
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(isAero ? 16 : 8),
          child: bar,
        ),
      ),
    );
  }
}

class _MiniDisc extends StatelessWidget {
  const _MiniDisc({required this.songId, required this.spinning});

  final int songId;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryController>();
    return FutureBuilder(
      future: library.artwork(songId),
      builder: (context, snapshot) => VinylDisc(
        size: 44,
        artwork: snapshot.data,
        spinning: spinning,
      ),
    );
  }
}

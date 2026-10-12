import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../state/library_controller.dart';
import '../state/playback_controller.dart';
import '../theme/app_theme.dart';
import '../theme/backgrounds.dart';
import '../theme/shapes.dart';
import '../widgets/disc.dart';
import '../widgets/status_views.dart';
import '../widgets/transport_controls.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackController>();
    final song = playback.currentSong;
    final text = Theme.of(context).textTheme;
    final isAero = context.isAero;
    final size = MediaQuery.sizeOf(context);

    if (song == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('NOW PLAYING'),
        ),
        body: const StatusMessage(
          icon: Icons.music_off,
          title: 'NOTHING PLAYING',
          subtitle: 'Pick a folder and tap a disc to start listening.',
        ),
      );
    }

    final duration = playback.duration ?? Duration.zero;
    final position = playback.position;
    final maxMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds
        .clamp(0, maxMs > 0 ? maxMs : 0)
        .toDouble();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('NOW PLAYING'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          // Phantom: flat electric-blue plate leaning behind the vinyl.
          if (context.isPhantom)
            Positioned(
              top: size.height * 0.10 + 14,
              right: -size.width * 0.42 + 14,
              child: Transform.rotate(
                angle: -0.07,
                child: Container(
                  width: size.width * 1.35,
                  height: size.width * 1.35,
                  color: PhantomPalette.blue.withValues(alpha: 0.55),
                ),
              ),
            ),
          // Oversized spinning disc, ~2/3 visible on the right.
          Positioned(
            top: size.height * 0.10,
            right: -size.width * 0.42,
            child: _NowPlayingDisc(songId: song.id, spinning: playback.playing),
          ),
          // HUD-style info band on the left over the disc edge.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 86),
                  Expanded(
                    flex: 12,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: _InfoBand(
                          isAero: isAero,
                          song: song,
                          text: text,
                          position: playback.queuePosition,
                          length: playback.queueLength,
                        ),
                      ),
                  ),
                  const Spacer(flex: 4),
                  // Seek bar.
                  Slider(
                    value: posMs,
                    max: maxMs > 0 ? maxMs : 1,
                    onChanged: maxMs > 0
                        ? (v) =>
                            playback.seek(Duration(milliseconds: v.round()))
                        : null,
                  ),
                  if (isAero)
                    _LcdStrip(
                      elapsed: _fmt(position),
                      remaining: maxMs > 0 ? '-${_fmt(duration - position)}' : '--:--',
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fmt(position),
                          style: text.labelMedium?.copyWith(
                            color: context.isPhantom
                                ? PhantomPalette.yellow
                                : P3Palette.yellow,
                          ),
                        ),
                        if (context.isPhantom)
                          Transform.rotate(
                            angle: 0.4,
                            child: Container(
                              width: 3,
                              height: 13,
                              color: PhantomPalette.muted,
                            ),
                          ),
                        Text(
                          maxMs > 0 ? '-${_fmt(duration - position)}' : '--:--',
                          style: text.labelSmall,
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  TransportControls(playback: playback),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBand extends StatelessWidget {
  const _InfoBand({
    required this.isAero,
    required this.song,
    required this.text,
    this.position,
    this.length = 0,
  });

  final bool isAero;
  final Song song;
  final TextTheme text;
  final int? position;
  final int length;

  @override
  Widget build(BuildContext context) {
    final isPhantom = context.isPhantom;
    final badge = isPhantom
        ? ClipPath(
            clipper: ShapeBorderClipper(
                shape: SlantBorder(slant: 6, side: BorderSide.none)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              color: PhantomPalette.yellow,
              child: Text(
                'NOW PLAYING',
                style: text.labelSmall?.copyWith(
                  color: PhantomPalette.bg,
                ),
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(
                color: isAero ? AeroPalette.primary : P3Palette.yellow,
              ),
              borderRadius: BorderRadius.circular(isAero ? 999 : 3),
              color: isAero
                  ? Colors.white.withValues(alpha: 0.7)
                  : P3Palette.bg.withValues(alpha: 0.7),
            ),
            child: Text(
              'NOW PLAYING',
              style: text.labelSmall?.copyWith(
                color: isAero ? AeroPalette.primary : P3Palette.yellow,
              ),
            ),
          );
    final numbering = Text(
      position == null
          ? ''
          : 'TRACK ${position.toString().padLeft(2, '0')}'
              ' / ${length.toString().padLeft(2, '0')}',
      style: text.labelSmall?.copyWith(
        color: isAero
            ? AeroPalette.textSecondary
            : isPhantom
                ? PhantomPalette.blue
                : P3Palette.textSecondary,
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            badge,
            const SizedBox(width: 10),
            numbering,
          ],
        ),
        const SizedBox(height: 10),
        Text(
          song.title,
          style:
              (isAero ? text.displayMedium : text.headlineLarge)?.copyWith(
            color: isAero
                ? AeroPalette.textPrimary
                : isPhantom
                    ? PhantomPalette.text
                    : P3Palette.textPrimary,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (isPhantom) ...[
          const SizedBox(height: 7),
          // Yellow/blue slash under the title.
          Row(
            children: [
              Container(width: 58, height: 5, color: PhantomPalette.yellow),
              const SizedBox(width: 5),
              Container(width: 14, height: 5, color: PhantomPalette.blue),
            ],
          ),
          const SizedBox(height: 6),
        ] else
          const SizedBox(height: 4),
        Text(
          song.artist,
          style: text.titleMedium?.copyWith(
            color: isAero
                ? AeroPalette.textSecondary
                : isPhantom
                    ? PhantomPalette.muted
                    : P3Palette.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (song.album.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            song.album,
            style: text.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
    if (isAero) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 18, 14),
        decoration: AeroPalette.panelDecoration(
            radius: BorderRadius.circular(18)),
        child: content,
      );
    }
    if (isPhantom) {
      // Phantom: ink plate with a hard electric-blue offset block and a
      // yellow edge tick.
      return Container(
        padding: const EdgeInsets.fromLTRB(15, 13, 22, 15),
        decoration: ShapeDecoration(
          color: PhantomPalette.ink.withValues(alpha: 0.94),
          shadows: [
            BoxShadow(
              color: PhantomPalette.blue.withValues(alpha: 0.55),
              offset: const Offset(6, 6),
            ),
          ],
          shape: const CutCornerBorder(
            radius: 12,
            diagonal: true,
            side: BorderSide(color: PhantomPalette.hairline),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 4, color: PhantomPalette.yellow),
            const SizedBox(height: 10),
            content,
          ],
        ),
      );
    }
    // Persona: angular HUD panel with a hard offset shadow.
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 22, 15),
      decoration: ShapeDecoration(
        color: P3Palette.bg.withValues(alpha: 0.88),
        shadows: const [
          BoxShadow(color: Color(0xE602050B), offset: Offset(4, 4)),
        ],
        shape: const CutCornerBorder(
          radius: 12,
          diagonal: true,
          side: BorderSide(color: P3Palette.outline),
        ),
      ),
      child: content,
    );
  }
}

/// Small inset LCD readout for elapsed / remaining time (Aero).
class _LcdStrip extends StatelessWidget {
  const _LcdStrip({required this.elapsed, required this.remaining});

  final String elapsed;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x660A2B44),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B5A85), Color(0xFF0E3552)],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            elapsed,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontVariations: [FontVariation('wght', 700)],
              fontSize: 13,
              letterSpacing: 2,
              color: Color(0xFFD9F5FF),
            ),
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 12, color: Colors.white24),
          const SizedBox(width: 14),
          Text(
            remaining,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontVariations: const [FontVariation('wght', 700)],
              fontSize: 13,
              letterSpacing: 2,
              color: const Color(0xFFD9F5FF).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingDisc extends StatelessWidget {
  const _NowPlayingDisc({required this.songId, required this.spinning});

  final int songId;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryController>();
    final discSize = MediaQuery.sizeOf(context).width * 1.35;
    return FutureBuilder<Uint8List?>(
      future: library.artwork(songId),
      builder: (context, snapshot) => VinylDisc(
        size: discSize,
        artwork: snapshot.data,
        spinning: spinning,
      ),
    );
  }
}

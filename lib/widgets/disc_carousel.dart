import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../state/library_controller.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/shapes.dart';
import 'disc.dart';

/// Horizontal swipeable carousel of song discs.
class DiscCarousel extends StatefulWidget {
  const DiscCarousel({
    super.key,
    required this.songs,
    this.initialIndex = 0,
    required this.onSongTap,
    this.onIndexChanged,
  });

  final List<Song> songs;
  final int initialIndex;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<int>? onIndexChanged;

  @override
  State<DiscCarousel> createState() => _DiscCarouselState();
}

class _DiscCarouselState extends State<DiscCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: 0.62,
    initialPage: widget.initialIndex,
  );
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    return PageView.builder(
      controller: _controller,
      itemCount: widget.songs.length,
      onPageChanged: (i) {
        setState(() => _index = i);
        widget.onIndexChanged?.call(i);
      },
      itemBuilder: (context, i) {
        final song = widget.songs[i];
        final active = i == _index;
        final distance = (i - _index).abs().toDouble();
        final scale = (1 - distance * 0.12).clamp(0.7, 1.0).toDouble();
        final discSize = MediaQuery.sizeOf(context).width * 0.5;
        return GestureDetector(
          onTap: () => widget.onSongTap(song),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phantom: the selected disc leans forward with a snap.
                if (isPhantom)
                  AnimatedScale(
                    scale: scale * (active ? 1.05 : 1.0),
                    duration: motionDuration(context, 180),
                    curve: Curves.easeOutBack,
                    child: _DiscWithArtwork(
                      song: song,
                      size: discSize,
                      emphasis: active,
                    ),
                  )
                else
                  Transform.scale(
                    scale: scale,
                    child: _DiscWithArtwork(
                      song: song,
                      size: discSize,
                      emphasis: active,
                    ),
                  ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: (1 - distance * 0.45).clamp(0.2, 1.0).toDouble(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPhantom && active)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            'TRACK ${(i + 1).toString().padLeft(2, '0')}'
                            ' / ${widget.songs.length.toString().padLeft(2, '0')}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: PhantomPalette.yellow),
                          ),
                        ),
                      Text(
                        song.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: active
                                  ? (isAero
                                      ? AeroPalette.textPrimary
                                      : PhantomPalette.text)
                                  : (isPhantom
                                      ? PhantomPalette.muted
                                      : null),
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      // Selection marker: bar (P3) / pill (Aero) /
                      // leaning parallelogram cursor (Phantom).
                      if (isPhantom)
                        AnimatedContainer(
                          duration: motionDuration(context, 160),
                          curve: Curves.easeOut,
                          width: active ? 46 : 0,
                          height: 9,
                          decoration: ShapeDecoration(
                            color: PhantomPalette.yellow,
                            shape: SlantBorder(
                              slant: 6,
                              side: BorderSide.none,
                            ),
                          ),
                        )
                      else
                        AnimatedContainer(
                          duration: motionDuration(context, 160),
                          curve: Curves.easeOut,
                          width: active ? 44 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isAero
                                ? AeroPalette.primary
                                : P3Palette.yellow,
                            borderRadius:
                                BorderRadius.circular(isAero ? 999 : 0),
                          ),
                        ),
                    ],
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

class _DiscWithArtwork extends StatelessWidget {
  const _DiscWithArtwork({
    required this.song,
    required this.size,
    this.emphasis = false,
  });

  final Song song;
  final double size;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryController>();
    return FutureBuilder(
      future: library.artwork(song.id),
      builder: (context, snapshot) => VinylDisc(
        size: size,
        artwork: snapshot.data,
        spinning: false,
        emphasis: emphasis,
      ),
    );
  }
}

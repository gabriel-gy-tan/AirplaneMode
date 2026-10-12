import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music_folder.dart';
import '../models/song.dart';
import '../state/library_controller.dart';
import '../state/playback_controller.dart';
import '../theme/app_theme.dart';
import '../theme/backgrounds.dart';
import '../theme/motion.dart';
import '../theme/shapes.dart';
import '../widgets/disc_carousel.dart';
import '../widgets/mini_player.dart';
import '../widgets/sort_sheet.dart';
import 'now_playing_screen.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key, required this.folder});

  final MusicFolder folder;

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final ScrollController _listController = ScrollController();

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  void _scrollToListIndex(int index) {
    if (!_listController.hasClients) return;
    // ~56px row height + panel padding.
    final target = (index * 56.0).clamp(0.0, _listController.position.maxScrollExtent);
    _listController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final playback = context.watch<PlaybackController>();
    final size = MediaQuery.sizeOf(context);

    // Resolve the folder again so sort changes apply live.
    final current = library.folders.firstWhere(
      (f) => f.path == widget.folder.path,
      orElse: () => widget.folder,
    );
    final songs = library.sortedSongsIn(current);
    final currentId = playback.currentSong?.id;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          current.name.toUpperCase(),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onPressed: () => showSortSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          if (songs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('This folder has no playable tracks.'),
              ),
            )
          else
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 76),
                  // Disc carousel on top.
                  SizedBox(
                    height: (size.height * 0.34).clamp(260.0, 320.0),
                    child: DiscCarousel(
                      songs: songs,
                      onSongTap: (Song song) {
                        final index = songs.indexWhere((s) => s.id == song.id);
                        playback.playSongs(songs,
                            startIndex: index < 0 ? 0 : index);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NowPlayingScreen()),
                        );
                      },
                      onIndexChanged: _scrollToListIndex,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Track list "sleeve" below the discs.
                  Expanded(
                    child: Padding(
                      // Leave room for the mini-player when something is loaded.
                      padding: EdgeInsets.only(
                          bottom: playback.currentSong != null ? 76 : 12),
                      child: ThemedPanel(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                              child: Row(
                                children: [
                                  if (context.isPhantom) ...[
                                    Container(
                                        width: 10,
                                        height: 10,
                                        color: PhantomPalette.yellow),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      'TRACKS · ${songs.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      playback.playSongs(songs, startIndex: 0);
                                    },
                                    icon: const Icon(Icons.play_arrow,
                                        size: 20),
                                    label: const Text('PLAY ALL'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Expanded(
                              child: ListView.builder(
                                controller: _listController,
                                itemCount: songs.length,
                                itemBuilder: (context, i) {
                                  final song = songs[i];
                                  final active = song.id == currentId;
                                  return _TrackTile(
                                    index: i,
                                    song: song,
                                    active: active,
                                    playing:
                                        active && playback.playing,
                                    durationLabel: _fmt(song.duration),
                                    onTap: () {
                                      playback.playSongs(songs,
                                          startIndex: i);
                                    },
                                    onLongPress: () {
                                      playback.playSongs(songs,
                                          startIndex: i);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const NowPlayingScreen()),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(
              onOpen: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.index,
    required this.song,
    required this.active,
    required this.playing,
    required this.durationLabel,
    required this.onTap,
    required this.onLongPress,
  });

  final int index;
  final Song song;
  final bool active;
  final bool playing;
  final String durationLabel;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final text = Theme.of(context).textTheme;
    final activeColor = isAero
        ? AeroPalette.primary
        : isPhantom
            ? PhantomPalette.yellow
            : P3Palette.yellow;
    final idleColor = isAero
        ? AeroPalette.textSecondary
        : isPhantom
            ? PhantomPalette.muted
            : P3Palette.textSecondary;

    return Column(
      children: [
        if (index > 0)
          Divider(
            height: 1,
            indent: isAero ? 16 : 28,
            endIndent: 16,
            color: isAero
                ? AeroPalette.outline.withValues(alpha: 0.5)
                : isPhantom
                    ? PhantomPalette.hairline
                    : P3Palette.outline.withValues(alpha: 0.4),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: AnimatedContainer(
              duration: motionDuration(context, 160),
              curve: Curves.easeOut,
              height: 56,
              color: active
                  ? (isAero
                      ? const Color(0xFFE8F7FF)
                      : isPhantom
                          ? PhantomPalette.surface
                          : P3Palette.primary.withValues(alpha: 0.14))
                  : Colors.transparent,
              child: Row(
                children: [
                  // Selection marker: edge bar (P3/Aero) /
                  // leaning yellow cursor (Phantom).
                  if (isPhantom)
                    AnimatedContainer(
                      duration: motionDuration(context, 160),
                      curve: Curves.easeOut,
                      width: active ? 9 : 0,
                      height: 30,
                      margin: const EdgeInsets.only(left: 6, right: 4),
                      decoration: ShapeDecoration(
                        color: activeColor,
                        shape: SlantBorder(
                          slant: 4,
                          side: BorderSide.none,
                        ),
                      ),
                    )
                  else
                    AnimatedContainer(
                      duration: motionDuration(context, 160),
                      width: 4,
                      height: 56,
                      color: active ? activeColor : Colors.transparent,
                    ),
                  SizedBox(width: isPhantom ? 4 : 10),
                  SizedBox(
                    width: 26,
                    child: playing
                        ? Icon(Icons.graphic_eq, size: 18, color: activeColor)
                        : Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: text.labelMedium?.copyWith(
                              color: active ? activeColor : idleColor,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium?.copyWith(
                            color: active
                                ? (isAero
                                    ? AeroPalette.textPrimary
                                    : PhantomPalette.text)
                                : null,
                            fontWeight: active ? FontWeight.w700 : null,
                          ),
                        ),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(
                            color: active
                                ? (isPhantom ? PhantomPalette.muted : null)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      durationLabel,
                      style: text.labelSmall?.copyWith(
                        color: active ? activeColor : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small label chips used on Now Playing / folder headers.
class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    if (isPhantom) {
      return ClipPath(
        clipper: ShapeBorderClipper(
            shape: SlantBorder(slant: 6, side: BorderSide.none)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: PhantomPalette.yellow,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: PhantomPalette.bg,
                ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAero
            ? AeroPalette.primary.withValues(alpha: 0.12)
            : P3Palette.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(isAero ? 999 : 4),
        border: Border.all(
          color: isAero ? AeroPalette.outline : P3Palette.outline,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isAero ? AeroPalette.primary : P3Palette.yellow,
            ),
      ),
    );
  }
}

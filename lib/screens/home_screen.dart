import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music_folder.dart';
import '../state/library_controller.dart';
import '../state/playback_controller.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../widgets/disc.dart';
import '../widgets/folder_card.dart';
import '../widgets/mini_player.dart';
import '../widgets/sort_sheet.dart';
import '../widgets/status_views.dart';
import 'folder_screen.dart';
import 'now_playing_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AIRPLANEMODE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onPressed: library.status == LibraryStatus.ready
                ? () => showSortSheet(context)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _LibraryBody()),
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

class _LibraryBody extends StatelessWidget {
  const _LibraryBody();

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();

    return SafeArea(
      child: switch (library.status) {
        LibraryStatus.initial || LibraryStatus.loading => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DiscLoadingIndicator(size: 84),
                SizedBox(height: 24),
                Text('SCANNING LIBRARY…'),
              ],
            ),
          ),
        LibraryStatus.permissionNeeded => StatusMessage(
            icon: Icons.folder_off,
            title: 'ACCESS NEEDED',
            subtitle:
                'AirplaneMode needs permission to read the music files on this device.',
            actionLabel: 'GRANT ACCESS',
            onAction: () => context.read<LibraryController>().load(force: true),
          ),
        LibraryStatus.empty => StatusMessage(
            icon: Icons.music_off,
            title: 'NO MUSIC FOUND',
            subtitle:
                'Drop some MP3s into a folder on this device and they will show up here.',
            actionLabel: 'RESCAN',
            onAction: () => context.read<LibraryController>().load(force: true),
          ),
        LibraryStatus.error => StatusMessage(
            icon: Icons.error_outline,
            title: 'SCAN FAILED',
            subtitle: 'Something went wrong while scanning. ${library.error ?? ''}',
            actionLabel: 'TRY AGAIN',
            onAction: () => context.read<LibraryController>().load(force: true),
          ),
        LibraryStatus.ready => _FolderGrid(folders: library.folders),
      },
    );
  }
}

class _FolderGrid extends StatelessWidget {
  const _FolderGrid({required this.folders});

  final List<MusicFolder> folders;

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotionOf(context);
    final text = Theme.of(context).textTheme;
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final trackCount =
        folders.fold<int>(0, (sum, f) => sum + f.songs.length);

    // Folder that contains the currently loaded track (Phantom selection).
    final currentId = context.watch<PlaybackController>().currentSong?.id;
    String? activePath;
    if (currentId != null) {
      for (final f in folders) {
        if (f.songs.any((s) => s.id == currentId)) {
          activePath = f.path;
          break;
        }
      }
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 14),
            child: isPhantom
                ? _PhantomHeader(
                    folderCount: folders.length,
                    trackCount: trackCount,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isAero)
                        Container(
                          width: 5,
                          height: 26,
                          margin: const EdgeInsets.only(right: 10, bottom: 2),
                          color: P3Palette.yellow,
                        ),
                      Text('LIBRARY', style: text.headlineMedium),
                      const Spacer(),
                      Text(
                        '${folders.length} ${folders.length == 1 ? 'FOLDER' : 'FOLDERS'}'
                        '  ·  $trackCount TRACKS',
                        style: text.labelSmall,
                      ),
                    ],
                  ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final folder = folders[i];
                return FolderCard(
                  folder: folder,
                  index: i + 1,
                  active: folder.path == activePath,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: reduce
                            ? Duration.zero
                            : Duration(
                                milliseconds: isPhantom ? 220 : 300),
                        pageBuilder: (_, _, _) => FolderScreen(folder: folder),
                        transitionsBuilder: (_, animation, _, child) {
                          if (reduce) return child;
                          // Brief lateral slide — the Persona snap-forward;
                          // Phantom cuts in diagonally.
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          );
                          return FadeTransition(
                            opacity: curved,
                            child: SlideTransition(
                              position: Tween(
                                begin: isPhantom
                                    ? const Offset(0.07, 0.05)
                                    : const Offset(0.04, 0.03),
                                end: Offset.zero,
                              ).animate(curved),
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              childCount: folders.length,
            ),
          ),
        ),
      ],
    );
  }
}

/// Phantom: oversized display title with tiny technical metadata.
class _PhantomHeader extends StatelessWidget {
  const _PhantomHeader({required this.folderCount, required this.trackCount});

  final int folderCount;
  final int trackCount;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    String two(int v) => v.toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 9, height: 9, color: PhantomPalette.yellow),
            const SizedBox(width: 7),
            Text(
              'AIRPLANEMODE // SOUND ARCHIVE',
              style: text.labelSmall?.copyWith(letterSpacing: 2.6),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('MUSIC', style: text.displayLarge),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'SELECT',
                  style: text.displayLarge
                      ?.copyWith(color: PhantomPalette.yellow),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(width: 14, height: 4, color: PhantomPalette.blue),
            const SizedBox(width: 8),
            Text(
              'COLLECTIONS: ${two(folderCount)}',
              style: text.labelLarge,
            ),
            const SizedBox(width: 14),
            Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 3,
                height: 14,
                color: PhantomPalette.muted,
              ),
            ),
            const SizedBox(width: 14),
            Text('TRACKS: ${two(trackCount)}', style: text.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(width: 52, height: 5, color: PhantomPalette.yellow),
            const SizedBox(width: 5),
            Container(width: 16, height: 5, color: PhantomPalette.blue),
          ],
        ),
      ],
    );
  }
}

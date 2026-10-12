import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../state/library_controller.dart';

/// Loads and displays artwork for a song, with a themed placeholder.
class SongArtwork extends StatelessWidget {
  const SongArtwork({
    super.key,
    required this.song,
    this.size,
    this.borderRadius,
  });

  final Song song;
  final double? size;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryController>();
    return FutureBuilder<Uint8List?>(
      future: library.artwork(song.id),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return Icon(Icons.music_note,
              size: size != null ? size! * 0.5 : 28,
              color: Theme.of(context).iconTheme.color);
        }
        final img = Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => Icon(Icons.music_note,
              size: size != null ? size! * 0.5 : 28),
        );
        if (borderRadius != null) {
          return ClipRRect(borderRadius: borderRadius!, child: img);
        }
        return img;
      },
    );
  }
}

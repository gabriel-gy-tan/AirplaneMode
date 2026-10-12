import 'song.dart';

class MusicFolder {
  const MusicFolder({
    required this.path,
    required this.name,
    required this.songs,
  });

  final String path;
  final String name;
  final List<Song> songs;

  Song? get coverSong => songs.isEmpty
      ? null
      : songs.reduce((a, b) => (a.dateAdded ?? DateTime(0)).isAfter(b.dateAdded ?? DateTime(0)) ? a : b);
}

class SongSortOption {
  const SongSortOption(this.id, this.label);

  final String id;
  final String label;

  static const title = SongSortOption('title', 'Title (A–Z)');
  static const artist = SongSortOption('artist', 'Artist (A–Z)');
  static const newest = SongSortOption('newest', 'Date added (newest)');
  static const oldest = SongSortOption('oldest', 'Date added (oldest)');
  static const released = SongSortOption('released', 'Date released (newest)');
  static const longest = SongSortOption('longest', 'Duration (longest)');
  static const fileName = SongSortOption('fileName', 'File name');

  static const all = [title, artist, newest, oldest, released, longest, fileName];

  static SongSortOption byId(String? id) =>
      all.firstWhere((o) => o.id == id, orElse: () => title);
}

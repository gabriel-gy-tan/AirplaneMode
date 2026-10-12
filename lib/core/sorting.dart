import '../models/music_folder.dart';
import '../models/song.dart';

/// Groups songs by the folder they physically live in.
Map<String, List<Song>> groupByFolderPath(List<Song> songs) {
  final map = <String, List<Song>>{};
  for (final song in songs) {
    map.putIfAbsent(song.folderPath, () => []).add(song);
  }
  return map;
}

String folderDisplayName(String path) {
  final normalized = path.replaceAll(RegExp(r'[/\\]+$'), '');
  final idx = normalized.lastIndexOf(RegExp(r'[/\\]'));
  final name = idx >= 0 ? normalized.substring(idx + 1) : normalized;
  return name.isEmpty ? path : name;
}

/// Sorts using [option]. [years] maps song id → release year (optional).
List<Song> sortSongs(
  List<Song> songs,
  SongSortOption option,
  Map<int, int> years,
) {
  final sorted = List<Song>.of(songs);
  int cmpText(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

  switch (option.id) {
    case 'artist':
      sorted.sort((a, b) {
        final r = cmpText(a.artist, b.artist);
        return r != 0 ? r : cmpText(a.title, b.title);
      });
    case 'newest':
      sorted.sort((a, b) =>
          (b.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0)));
    case 'oldest':
      sorted.sort((a, b) =>
          (a.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(b.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0)));
    case 'released':
      sorted.sort((a, b) {
        final ya = years[a.id] ?? 0;
        final yb = years[b.id] ?? 0;
        final r = yb.compareTo(ya);
        return r != 0 ? r : cmpText(a.title, b.title);
      });
    case 'longest':
      sorted.sort((a, b) => b.duration.compareTo(a.duration));
    case 'fileName':
      sorted.sort((a, b) => cmpText(a.fileName, b.fileName));
    case 'title':
    default:
      sorted.sort((a, b) => cmpText(a.title, b.title));
  }
  return sorted;
}

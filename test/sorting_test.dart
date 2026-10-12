import 'package:airplanemode/core/sorting.dart';
import 'package:airplanemode/models/music_folder.dart';
import 'package:airplanemode/models/song.dart';
import 'package:flutter_test/flutter_test.dart';

Song _song({
  int id = 1,
  String title = 'Title',
  String artist = 'Artist',
  String folder = '/storage/emulated/0/Music/Album',
  Duration duration = const Duration(minutes: 3),
  DateTime? dateAdded,
}) {
  final path = '$folder/$title.mp3';
  return Song(
    id: id,
    title: title,
    artist: artist,
    album: 'Album',
    filePath: path,
    fileName: '$title.mp3',
    folderPath: folder,
    duration: duration,
    dateAdded: dateAdded,
  );
}

void main() {
  group('groupByFolderPath', () {
    test('groups songs by physical folder', () {
      final songs = [
        _song(id: 1, title: 'A', folder: '/m/one'),
        _song(id: 2, title: 'B', folder: '/m/two'),
        _song(id: 3, title: 'C', folder: '/m/one'),
      ];
      final grouped = groupByFolderPath(songs);
      expect(grouped.keys, hasLength(2));
      expect(grouped['/m/one'], hasLength(2));
      expect(grouped['/m/two'], hasLength(1));
    });
  });

  group('folderDisplayName', () {
    test('extracts the leaf folder name', () {
      expect(folderDisplayName('/storage/emulated/0/Music/Cool Album'),
          'Cool Album');
      expect(folderDisplayName('/storage/emulated/0/Music/Cool Album/'), 'Cool Album');
      expect(folderDisplayName('solo'), 'solo');
    });
  });

  group('sortSongs', () {
    final songs = [
      _song(id: 1, title: 'Bravo', artist: 'Zed', dateAdded: DateTime(2020)),
      _song(id: 2, title: 'alpha', artist: 'amy', dateAdded: DateTime(2022),
          duration: const Duration(minutes: 5)),
      _song(id: 3, title: 'Charlie', artist: 'Bob', dateAdded: DateTime(2021)),
    ];

    test('title A-Z is case-insensitive', () {
      final sorted = sortSongs(songs, SongSortOption.title, {});
      expect(sorted.map((s) => s.title), ['alpha', 'Bravo', 'Charlie']);
    });

    test('artist A-Z', () {
      final sorted = sortSongs(songs, SongSortOption.artist, {});
      expect(sorted.map((s) => s.artist), ['amy', 'Bob', 'Zed']);
    });

    test('newest first', () {
      final sorted = sortSongs(songs, SongSortOption.newest, {});
      expect(sorted.first.id, 2);
      expect(sorted.last.id, 1);
    });

    test('longest first', () {
      final sorted = sortSongs(songs, SongSortOption.longest, {});
      expect(sorted.first.id, 2);
    });

    test('release year newest first, unknown years last', () {
      final sorted =
          sortSongs(songs, SongSortOption.released, {1: 1999, 3: 2015});
      expect(sorted.map((s) => s.id), [3, 1, 2]);
    });

    test('file name', () {
      final sorted = sortSongs(songs, SongSortOption.fileName, {});
      expect(sorted.first.fileName, 'alpha.mp3');
    });
  });
}

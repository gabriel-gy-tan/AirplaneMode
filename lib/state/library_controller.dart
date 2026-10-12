import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/sorting.dart';
import '../data/library_repository.dart';
import '../models/music_folder.dart';
import '../models/song.dart';

enum LibraryStatus { initial, loading, permissionNeeded, ready, empty, error }

class LibraryController extends ChangeNotifier {
  LibraryController(this._repository);

  final LibraryRepository _repository;

  LibraryStatus status = LibraryStatus.initial;
  List<Song> songs = [];
  List<MusicFolder> folders = [];
  Map<int, int> years = {};
  Object? error;
  bool yearsLoaded = false;

  SongSortOption _sortOption = SongSortOption.title;
  SongSortOption get sortOption => _sortOption;

  Future<void> load({bool force = false}) async {
    if (status == LibraryStatus.loading) return;
    if (status == LibraryStatus.ready && !force) return;
    status = LibraryStatus.loading;
    error = null;
    notifyListeners();

    try {
      final granted = await _repository.ensurePermission();
      if (!granted) {
        status = LibraryStatus.permissionNeeded;
        notifyListeners();
        return;
      }
      final loaded = await _repository.loadSongs();
      songs = loaded;
      yearsLoaded = false;
      years = {};
      if (loaded.isEmpty) {
        status = LibraryStatus.empty;
      } else {
        status = LibraryStatus.ready;
        _rebuild();
        notifyListeners();
        unawaited(_loadYears());
      }
      notifyListeners();
    } catch (e) {
      error = e;
      status = LibraryStatus.error;
      notifyListeners();
    }
  }

  Future<void> _loadYears() async {
    try {
      final result = await _repository.loadYears(songs);
      years = result;
      yearsLoaded = true;
      _rebuild();
      notifyListeners();
    } catch (_) {
      // Year sorting simply won't have data.
    }
  }

  Future<Uint8List?> artwork(int songId) => _repository.artwork(songId);

  Future<Uri?> writeArtworkFile(Song song) async {
    final bytes = await _repository.artwork(song.id);
    if (bytes == null) return null;
    final file = File(
        '${Directory.systemTemp.path}/airplanemode_art_${song.id}.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return Uri.file(file.path);
  }

  void setSortOption(SongSortOption option) {
    _sortOption = option;
    _rebuild();
    notifyListeners();
  }

  List<Song> sortedSongsIn(MusicFolder folder) =>
      sortSongs(folder.songs, _sortOption, years);

  List<Song> get allSongsSorted => sortSongs(songs, _sortOption, years);

  void _rebuild() {
    final grouped = groupByFolderPath(songs);
    final list = grouped.entries
        .map((e) => MusicFolder(
              path: e.key,
              name: folderDisplayName(e.key),
              songs: sortSongs(e.value, _sortOption, years),
            ))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    folders = list;
  }
}

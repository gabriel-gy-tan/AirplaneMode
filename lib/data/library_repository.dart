import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song.dart';
import 'artwork_cache.dart';

class LibraryRepository {
  LibraryRepository() : _query = OnAudioQuery();

  final OnAudioQuery _query;
  final ArtworkCache _artworkCache = ArtworkCache();

  /// Returns true when the user granted audio access.
  Future<bool> ensurePermission() async {
    var status = await Permission.audio.status;
    if (!status.isGranted) {
      status = await Permission.audio.request();
    }
    if (status.isPermanentlyDenied) {
      return false;
    }
    if (status.isGranted) {
      // Best-effort: notification permission for playback controls (Android 13+).
      await Permission.notification.request();
      return true;
    }
    // Older devices / odd OEMs: fall back to the plugin's own request.
    if (!await _query.permissionsStatus()) {
      return await _query.permissionsRequest();
    }
    return status.isGranted;
  }

  static const _audioExtensions = {'mp3', 'm4a', 'flac', 'ogg', 'aac', 'opus', 'wma'};

  Future<List<Song>> loadSongs() async {
    final models = await _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
    );
    final songs = <Song>[];
    for (final m in models) {
      final path = m.data.toLowerCase();
      final ext = m.fileExtension.toLowerCase();
      if (!_audioExtensions.contains(ext) && !_audioExtensions.contains(path.split('.').last)) {
        continue;
      }
      if (m.isMusic == false) continue;
      songs.add(Song.fromAudioModel(m));
    }
    return songs;
  }

  Future<Uint8List?> artwork(int songId) {
    return _artworkCache.getOrFetch(songId, () async {
      final bytes = await _query.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        size: 600,
        format: ArtworkFormat.JPEG,
      );
      return bytes;
    });
  }

  void invalidateArtwork() => _artworkCache.clear();

  /// Reads the release year from ID3 tags with bounded concurrency.
  Future<Map<int, int>> loadYears(List<Song> songs) async {
    final years = <int, int>{};
    const workers = 6;
    var index = 0;

    Future<void> worker() async {
      while (true) {
        final i = index++;
        if (i >= songs.length) return;
        final song = songs[i];
        final year = await _readYear(song);
        if (year != null) {
          years[song.id] = year;
        }
      }
    }

    await Future.wait(List.generate(workers, (_) => worker()));
    return years;
  }

  Future<int?> _readYear(Song song) async {
    try {
      final file = File(song.filePath);
      if (!await file.exists()) return null;
      final meta = await AudioMetadata.extract(file);
      final date = meta?.date;
      if (date == null) return null;
      final match = RegExp(r'(\d{4})').firstMatch(date);
      if (match == null) return null;
      final year = int.tryParse(match.group(1)!);
      if (year == null || year < 1000 || year > 3000) return null;
      return year;
    } catch (_) {
      return null;
    }
  }
}

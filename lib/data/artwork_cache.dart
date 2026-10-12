import 'dart:typed_data';

/// Small in-memory LRU cache for album artwork fetched from MediaStore.
class ArtworkCache {
  ArtworkCache({this.capacity = 160});

  final int capacity;
  final _cache = <int, Future<Uint8List?>>{};

  Future<Uint8List?> getOrFetch(int songId, Future<Uint8List?> Function() fetch) {
    return _cache.putIfAbsent(songId, fetch).catchError((Object _) {
      _cache.remove(songId);
      return null;
    });
  }

  void clear() => _cache.clear();
}

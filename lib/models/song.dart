import 'package:on_audio_query/on_audio_query.dart';

class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    required this.fileName,
    required this.folderPath,
    required this.duration,
    this.dateAdded,
    this.dateModified,
  });

  final int id;
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final String fileName;
  final String folderPath;
  final Duration duration;
  final DateTime? dateAdded;
  final DateTime? dateModified;

  static DateTime? _msOrSec(int? raw) {
    if (raw == null || raw <= 0) return null;
    // MediaStore sometimes reports seconds, sometimes milliseconds.
    final millis = raw < 100000000000 ? raw * 1000 : raw;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static String _cleanArtist(String? value) {
    if (value == null || value.trim().isEmpty || value == '<unknown>') {
      return 'Unknown artist';
    }
    return value.trim();
  }

  static String _cleanAlbum(String? value) {
    if (value == null || value.trim().isEmpty || value == '<unknown>') {
      return 'Unknown album';
    }
    return value.trim();
  }

  factory Song.fromAudioModel(SongModel model) {
    final path = model.data;
    final slash = path.lastIndexOf(RegExp(r'[/\\]'));
    final folder = slash > 0 ? path.substring(0, slash) : path;
    final file = slash >= 0 ? path.substring(slash + 1) : path;
    final title = (model.title.trim().isNotEmpty)
        ? model.title.trim()
        : file.replaceAll(RegExp(r'\.[^.]+$'), '');
    return Song(
      id: model.id,
      title: title,
      artist: _cleanArtist(model.artist),
      album: _cleanAlbum(model.album),
      filePath: path,
      fileName: file,
      folderPath: folder,
      duration: Duration(milliseconds: model.duration ?? 0),
      dateAdded: _msOrSec(model.dateAdded),
      dateModified: _msOrSec(model.dateModified),
    );
  }
}

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

/// Background-capable player: just_audio under the hood, exposed through
/// audio_service so the notification / lock screen can control it.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  AudioPlayerHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.currentIndexStream.listen((index) {
      if (index == null || index >= _songs.length) return;
      _broadcastItem(_songs[index]);
    });
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.completed));
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  List<Song> _songs = [];
  List<Song> get songs => _songs;

  AudioPlayer get player => _player;

  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    _songs = songs;
    final sources = songs
        .map((s) => AudioSource.file(s.filePath))
        .toList();
    await _player.setAudioSources(sources, initialIndex: startIndex);
    queue.add(songs.map(_toMediaItem).toList());
    await play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position, {int? index}) {
    if (index != null) {
      return _player.seek(position, index: index);
    }
    return _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
      await play();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
      await play();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future<void> setShuffle(bool enabled) => _player.setShuffleModeEnabled(enabled);

  Future<void> setPlayerRepeatMode(LoopMode mode) => _player.setLoopMode(mode);

  Future<void> dispose() => _player.dispose();

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (event.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: playing,
      updatePosition: _player.position,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    ));
  }

  void _broadcastItem(Song song) {
    final item = _toMediaItem(song);
    mediaItem.add(item);
    unawaited(_attachArtwork(item, song));
  }

  /// Set by the UI layer: given a song, writes its artwork to a cache file
  /// and returns a Uri usable by the media notification (or null).
  Future<Uri?> Function(Song song)? artworkFileResolver;

  Future<void> _attachArtwork(MediaItem item, Song song) async {
    try {
      final resolver = artworkFileResolver;
      if (resolver == null) return;
      final uri = await resolver(song);
      if (uri != null) {
        mediaItem.add(item.copyWith(artUri: uri));
      }
    } catch (_) {
      // Notification artwork is best-effort.
    }
  }

  MediaItem _toMediaItem(Song song) {
    return MediaItem(
      id: song.filePath,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
    );
  }
}

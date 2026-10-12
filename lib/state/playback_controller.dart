import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../services/audio_player_handler.dart';

/// UI-facing wrapper around [AudioPlayerHandler].
class PlaybackController extends ChangeNotifier {
  PlaybackController(this._handler) {
    _positionSub = _handler.player.positionStream.listen((position) {
      _position = position;
      _throttledNotify();
    });
    _durationSub = _handler.player.durationStream.listen((duration) {
      _duration = duration;
      notifyListeners();
    });
    _stateSub = _handler.player.playerStateStream.listen((state) {
      _playing = state.playing;
      notifyListeners();
    });
    _indexSub = _handler.player.currentIndexStream.listen((index) {
      if (index == null || index < 0 || index >= _handler.songs.length) return;
      _currentSong = _handler.songs[index];
      notifyListeners();
    });
    _queueSub = _handler.queue.listen((queue) {
      _queue = queue;
      notifyListeners();
    });
  }

  final AudioPlayerHandler _handler;

  Song? _currentSong;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration? _duration;
  List<MediaItem> _queue = [];
  bool _shuffle = false;
  LoopMode _repeatMode = LoopMode.off;

  Song? get currentSong => _currentSong;
  bool get playing => _playing;
  Duration get position => _position;
  Duration? get duration => _duration ?? _currentSong?.duration;
  List<MediaItem> get queue => _queue;
  bool get shuffle => _shuffle;
  LoopMode get repeatMode => _repeatMode;
  bool get hasNext => _handler.player.hasNext;
  bool get hasPrevious => _handler.player.hasPrevious;

  /// 1-based position of the current track within the play queue.
  int? get queuePosition {
    final i = _handler.player.currentIndex;
    if (i == null || i < 0 || _handler.songs.isEmpty) return null;
    return i + 1;
  }

  int get queueLength => _handler.songs.length;

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _indexSub;
  StreamSubscription? _queueSub;

  DateTime _lastNotify = DateTime.fromMillisecondsSinceEpoch(0);
  void _throttledNotify() {
    final now = DateTime.now();
    if (now.difference(_lastNotify).inMilliseconds >= 200) {
      _lastNotify = now;
      notifyListeners();
    }
  }

  Future<void> playSongs(List<Song> songs, {int startIndex = 0}) async {
    await _handler.playQueue(songs, startIndex: startIndex);
  }

  Future<void> playPause() async {
    if (_playing) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  Future<void> next() => _handler.skipToNext();
  Future<void> previous() => _handler.skipToPrevious();
  Future<void> seek(Duration position) => _handler.seek(position);

  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    await _handler.setShuffle(_shuffle);
    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    _repeatMode = switch (_repeatMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _handler.setPlayerRepeatMode(_repeatMode);
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _indexSub?.cancel();
    _queueSub?.cancel();
    super.dispose();
  }
}

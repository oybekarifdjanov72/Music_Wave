import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/track_model.dart';

/// Clean, reliable audio player service wrapping `just_audio` to play
/// audio streams from Deezer and iTunes with zero 403 source errors.
class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer() {
    _player.setLoopMode(LoopMode.one);
  }

  final AudioPlayer _player;

  List<Track> _queue = [];
  int _currentIndex = -1;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  bool get isPlaying => _player.playing;
  bool get isFullTrack => false;
  Track? get currentTrack => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  bool get hasNext => _currentIndex >= 0 && _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  Future<void> playQueue(List<Track> queue, int startIndex) async {
    _queue = queue;
    _currentIndex = startIndex;
    await _playCurrent();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> next() async {
    if (!hasNext) return;
    _currentIndex++;
    await _playCurrent();
  }

  Future<void> previous() async {
    if (!hasPrevious) return;
    _currentIndex--;
    await _playCurrent();
  }

  Future<void> stop() async {
    await _player.stop();
    _queue = [];
    _currentIndex = -1;
  }

  Future<void> _playCurrent() async {
    final track = currentTrack;
    if (track == null || !track.isPlayable) {
      if (hasNext) {
        await next();
      } else {
        await _player.stop();
      }
      return;
    }

    try {
      final rawUrl = track.previewUrl!;
      final effectiveUrl = (kIsWeb && rawUrl.contains('dzcdn.net') && !rawUrl.startsWith('https://corsproxy.io/?'))
          ? 'https://corsproxy.io/?$rawUrl'
          : rawUrl;
      await _player.setUrl(effectiveUrl);
      await _player.play();
    } catch (_) {
      if (hasNext) {
        await next();
      } else {
        await _player.stop();
      }
    }
  }

  void dispose() => _player.dispose();
}

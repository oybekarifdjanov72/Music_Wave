import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

import '../../../core/audio/audio_player_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/track_model.dart';
import '../../../core/storage/local_storage_service.dart';
import 'player_state.dart';

/// The one player that lives for the whole app session — provided once at
/// the root so the mini player bar (always visible) and the full "Now
/// Playing" screen (pushed on top) share the exact same playback state.
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({AudioPlayerService? audioPlayerService, LocalStorageService? storage})
      : _audioService = audioPlayerService ?? getIt<AudioPlayerService>(),
        _storage = storage ?? getIt<LocalStorageService>(),
        super(const PlayerState()) {
    _bind();
  }

  final AudioPlayerService _audioService;
  final LocalStorageService _storage;
  String? _lastRecordedTrackId;
  StreamSubscription<just_audio.PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  void _bind() {
    _playerStateSub = _audioService.playerStateStream.listen((playbackState) {
      final track = _audioService.currentTrack;
      if (track != null && track.id != _lastRecordedTrackId) {
        _lastRecordedTrackId = track.id;
        // Fire-and-forget: Home's "Recently Played" row reads this back
        // next time it loads.
        unawaited(_storage.addRecentlyPlayed(track));
      }
      emit(
        state.copyWith(
          isPlaying: playbackState.playing,
          isBuffering: playbackState.processingState == just_audio.ProcessingState.buffering ||
              playbackState.processingState == just_audio.ProcessingState.loading,
          currentTrack: track,
          clearTrack: track == null,
          isFullTrack: _audioService.isFullTrack,
          hasNext: _audioService.hasNext,
          hasPrevious: _audioService.hasPrevious,
        ),
      );
    });

    _positionSub = _audioService.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });

    _durationSub = _audioService.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration ?? Duration.zero));
    });
  }

  /// Starts playing [queue] from [startIndex]. Prefers full-length streams
  /// (via YouTube) and falls back to Deezer/iTunes previews when needed.
  Future<void> playQueue(List<Track> queue, int startIndex) async {
    if (queue.isEmpty) return;

    final safeIndex = startIndex.clamp(0, queue.length - 1);
    await _audioService.playQueue(queue, safeIndex);
    emit(
      state.copyWith(
        currentTrack: _audioService.currentTrack,
        isFullTrack: _audioService.isFullTrack,
        hasNext: _audioService.hasNext,
        hasPrevious: _audioService.hasPrevious,
      ),
    );
  }

  Future<void> togglePlayPause() => _audioService.togglePlayPause();

  Future<void> next() => _audioService.next();

  Future<void> previous() => _audioService.previous();

  Future<void> seek(Duration position) => _audioService.seek(position);

  @override
  Future<void> close() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    return super.close();
  }
}

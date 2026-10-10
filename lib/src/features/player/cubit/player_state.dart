import 'package:equatable/equatable.dart';

import '../../../core/models/track_model.dart';

class PlayerState extends Equatable {
  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isFullTrack = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  final Track? currentTrack;
  final bool isPlaying;
  final bool isBuffering;
  final bool isFullTrack;
  final Duration position;
  final Duration duration;
  final bool hasNext;
  final bool hasPrevious;

  bool get hasTrack => currentTrack != null;

  PlayerState copyWith({
    Track? currentTrack,
    bool clearTrack = false,
    bool? isPlaying,
    bool? isBuffering,
    bool? isFullTrack,
    Duration? position,
    Duration? duration,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    return PlayerState(
      currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isFullTrack: isFullTrack ?? this.isFullTrack,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
    );
  }

  @override
  List<Object?> get props => [
        currentTrack,
        isPlaying,
        isBuffering,
        isFullTrack,
        position,
        duration,
        hasNext,
        hasPrevious,
      ];
}

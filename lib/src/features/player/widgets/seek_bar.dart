import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Progress slider + elapsed/total time labels, used on the Now Playing
/// screen. Dragging seeks live; the visual value is optimistic (follows
/// the drag) so it never fights the user's thumb.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds.clamp(1, double.maxFinite.toInt()).toDouble();
    final positionMs = widget.position.inMilliseconds.clamp(0, totalMs.toInt()).toDouble();
    final sliderValue = _dragValue ?? positionMs;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.cyanAccent,
            inactiveTrackColor: AppColors.surfaceElevated,
            thumbColor: AppColors.cyanAccent,
            overlayColor: AppColors.cyanAccent.withValues(alpha: 0.2),
          ),
          child: Slider(
            min: 0,
            max: totalMs,
            value: sliderValue.clamp(0, totalMs),
            onChanged: (value) => setState(() => _dragValue = value),
            onChangeEnd: (value) {
              widget.onSeek(Duration(milliseconds: value.toInt()));
              setState(() => _dragValue = null);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(widget.position), style: AppTextStyles.caption),
              Text(_format(widget.duration), style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

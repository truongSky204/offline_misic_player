import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble().clamp(0.0, double.infinity);
    final value = position.inMilliseconds.toDouble().clamp(0.0, max);

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.grey.shade800,
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: max == 0 ? 0 : value,
            min: 0,
            max: max == 0 ? 1 : max,
            onChanged: (v) => onSeek(Duration(milliseconds: v.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(position), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(formatDuration(duration), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }
}

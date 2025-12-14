import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;
  const PlayerControls({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // shuffle + repeat
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: provider.isShuffleEnabled ? AppColors.primary : Colors.grey,
              ),
              onPressed: provider.toggleShuffle,
            ),
            IconButton(
              icon: Icon(
                provider.loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                color: provider.loopMode == LoopMode.off ? Colors.grey : AppColors.primary,
              ),
              onPressed: provider.toggleRepeat,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // prev - play - next
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
              onPressed: provider.previous,
            ),
            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (_, snap) {
                final playing = snap.data ?? false;
                return Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: IconButton(
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 42),
                    onPressed: provider.playPause,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
              onPressed: provider.next,
            ),
          ],
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AudioProvider>(
          builder: (_, provider, __) {
            final song = provider.currentSong;
            if (song == null) {
              return const Center(child: Text('No song playing', style: TextStyle(color: Colors.white)));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text('Now Playing', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 10))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AlbumArt(songId: int.tryParse(song.id) ?? 0, size: 300),
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(song.artist, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                StreamBuilder<Duration?>(
                  stream: provider.durationStream,
                  builder: (_, dSnap) {
                    final duration = dSnap.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: provider.positionStream,
                      builder: (_, pSnap) {
                        final position = pSnap.data ?? Duration.zero;
                        return ProgressBar(
                          position: position,
                          duration: duration,
                          onSeek: provider.seek,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 14),

                PlayerControls(provider: provider),

                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}

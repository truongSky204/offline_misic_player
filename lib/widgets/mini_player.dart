import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';
import '../utils/constants.dart';
import 'album_art.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            StreamBuilder<Duration?>(
              stream: provider.durationStream,
              builder: (_, dSnap) {
                final dur = dSnap.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: provider.positionStream,
                  builder: (_, pSnap) {
                    final pos = pSnap.data ?? Duration.zero;
                    final v = (dur.inMilliseconds == 0) ? 0.0 : pos.inMilliseconds / dur.inMilliseconds;
                    return LinearProgressIndicator(
                      value: v.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade800,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 2,
                    );
                  },
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    AlbumArt(songId: int.tryParse(song.id) ?? 0, size: 50),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          Text(song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: provider.playingStream,
                      builder: (_, snap) {
                        final playing = snap.data ?? false;
                        return IconButton(
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                          onPressed: provider.playPause,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: provider.next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

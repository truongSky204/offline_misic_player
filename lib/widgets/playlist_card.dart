import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../utils/constants.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  const PlaylistCard({super.key, required this.playlist, required this.onTap, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.queue_music, color: Colors.white),
        ),
        title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('${playlist.songIds.length} songs', style: const TextStyle(color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: onMore,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../utils/constants.dart';
import 'album_art.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  const SongTile({super.key, required this.song, required this.onTap, this.onMore});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: AlbumArt(songId: int.tryParse(song.id) ?? 0, size: 50),
      title: Text(
        song.title,
        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(color: AppColors.subText.shade400),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: onMore,
      ),
      onTap: onTap,
    );
  }
}

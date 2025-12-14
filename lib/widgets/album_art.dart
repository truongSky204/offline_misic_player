import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' as oq;
import '../utils/constants.dart';

class AlbumArt extends StatelessWidget {
  final int songId;
  final double size;

  const AlbumArt({super.key, required this.songId, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: oq.QueryArtworkWidget(
        id: songId,
        type: oq.ArtworkType.AUDIO,
        nullArtworkWidget: Container(
          width: size,
          height: size,
          color: AppColors.card,
          child: const Icon(Icons.music_note, color: Colors.grey),
        ),
        artworkBorder: BorderRadius.circular(6),
        artworkHeight: size,
        artworkWidth: size,
      ),
    );
  }
}

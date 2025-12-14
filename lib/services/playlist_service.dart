import 'package:on_audio_query/on_audio_query.dart' as oq;

import '../models/song_model.dart'; // SongModel của BẠN

class PlaylistService {
  final oq.OnAudioQuery _audioQuery = oq.OnAudioQuery();

  Future<List<SongModel>> getAllSongs() async {
    try {
      // SongModel của on_audio_query (alias là oq)
      final List<oq.SongModel> raw = await _audioQuery.querySongs(
        sortType: oq.SongSortType.TITLE,
        orderType: oq.OrderType.ASC_OR_SMALLER,
        uriType: oq.UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Map sang SongModel của bạn
      return raw.map((audio) => SongModel.fromAudioQuery(audio)).toList();
    } catch (e) {
      throw Exception('Error loading songs: $e');
    }
  }

  Future<List<SongModel>> searchSongs(String query) async {
    final all = await getAllSongs();
    final q = query.toLowerCase();

    return all.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q) ||
          (s.album ?? '').toLowerCase().contains(q);
    }).toList();
  }
}

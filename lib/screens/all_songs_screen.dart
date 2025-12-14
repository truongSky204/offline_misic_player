import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song_model.dart';
import '../providers/playlist_provider.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';

class AllSongsScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const AllSongsScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final PlaylistService _library = PlaylistService();
  final PermissionService _permission = PermissionService();

  bool _loading = true;
  bool _ok = false;
  List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
    });

    try {
      final ok = await _permission.requestAudioPermission();

      if (!mounted) return;

      setState(() => _ok = ok);

      if (ok) {
        final songs = await _library.getAllSongs();
        if (!mounted) return;
        setState(() => _songs = songs);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading songs: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();

    // ✅ tránh crash nếu playlist chưa tồn tại
    final playlist = playlistProvider.playlists
        .where((p) => p.id == widget.playlistId)
        .cast<dynamic?>()
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: Text('Add songs: ${widget.playlistName}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_ok
          ? _permissionDenied()
          : playlist == null
          ? _playlistNotFound()
          : ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (_, i) {
          final s = _songs[i];
          final bool added = playlist.songIds.contains(s.id);

          return SongTile(
            song: s,
            onTap: () async {
              if (added) {
                await context.read<PlaylistProvider>().removeSong(widget.playlistId, s.id);
              } else {
                await context.read<PlaylistProvider>().addSong(widget.playlistId, s.id);
              }
            },
            onMore: () {},
          );
        },
      ),
    );
  }

  Widget _permissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off, size: 80, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Permission required',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please allow audio permission to read your music library.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async => openAppSettings(),
              child: const Text('Open Settings'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _init,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playlistNotFound() {
    return const Center(
      child: Text(
        'Playlist not found.',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

/// ✅ tiện ích nhỏ để dùng firstOrNull mà không cần package
extension _FirstOrNullExt<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../utils/constants.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';

import 'playlist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _library = PlaylistService();
  final PermissionService _permission = PermissionService();

  bool _loading = true;
  bool _ok = false;
  List<SongModel> _songs = [];
  String _q = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
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
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _q.isEmpty
        ? _songs
        : _songs.where((s) {
      final q = _q.toLowerCase();
      return s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q) ||
          (s.album ?? '').toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            _search(),
            const SizedBox(height: 8),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : !_ok
                  ? _permissionDenied()
                  : filtered.isEmpty
                  ? _noSongs()
                  : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final song = filtered[i];
                  return SongTile(
                    song: song,
                    onTap: () => context.read<AudioProvider>().setPlaylist(filtered, i),
                    onMore: () => _songMenu(context, song),
                  );
                },
              ),
            ),

            Consumer<AudioProvider>(
              builder: (_, p, __) => p.currentSong == null ? const SizedBox() : const MiniPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'My Music',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaylistScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search songs, artists, albums...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (v) => setState(() => _q = v),
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
            const SizedBox(height: 10),
            const Text(
              'Permission required',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please allow audio permission to read music files.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
              },
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

  Widget _noSongs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.music_note, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text('No Music Found', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 6),
          Text('Add some music files to your device', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _songMenu(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.white),
              title: const Text('Play', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.read<AudioProvider>().setPlaylist(_songs, _songs.indexOf(song));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('Info', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                song.filePath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

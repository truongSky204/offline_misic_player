import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../widgets/playlist_card.dart';
import 'all_songs_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaylistProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _create(context),
          )
        ],
      ),
      body: provider.playlists.isEmpty
          ? const Center(child: Text('No playlists yet', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        itemCount: provider.playlists.length,
        itemBuilder: (_, i) {
          final p = provider.playlists[i];
          return PlaylistCard(
            playlist: p,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AllSongsScreen(playlistId: p.id, playlistName: p.name)),
            ),
            onMore: () => _playlistMenu(context, p.id, p.name),
          );
        },
      ),
    );
  }

  void _create(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Create playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Playlist name', hintStyle: TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );

    if (ok == true) {
      await context.read<PlaylistProvider>().createPlaylist(controller.text);
    }
  }

  void _playlistMenu(BuildContext context, String id, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Rename', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _rename(context, id, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<PlaylistProvider>().deletePlaylist(id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _rename(BuildContext context, String id, String oldName) async {
    final c = TextEditingController(text: oldName);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Rename playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: c,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok == true) {
      await context.read<PlaylistProvider>().renamePlaylist(id, c.text);
    }
  }
}

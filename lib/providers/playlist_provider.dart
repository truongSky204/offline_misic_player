import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService storage;
  List<PlaylistModel> _playlists = [];

  List<PlaylistModel> get playlists => _playlists;

  PlaylistProvider({required this.storage}) {
    _init();
  }

  Future<void> _init() async {
    _playlists = await storage.getPlaylists();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final p = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'New Playlist' : name.trim(),
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists = [..._playlists, p];
    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    _playlists = _playlists.map((p) {
      if (p.id != id) return p;
      return p.copyWith(name: newName.trim().isEmpty ? p.name : newName.trim());
    }).toList();

    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSong(String playlistId, String songId) async {
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      if (p.songIds.contains(songId)) return p;
      return p.copyWith(songIds: [...p.songIds, songId]);
    }).toList();

    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> removeSong(String playlistId, String songId) async {
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      final ids = [...p.songIds]..remove(songId);
      return p.copyWith(songIds: ids);
    }).toList();

    await storage.savePlaylists(_playlists);
    notifyListeners();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song_model.dart';
import '../services/audio_handler.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AppAudioHandler audioHandler;
  final StorageService storage;

  List<SongModel> _playlist = [];
  int _currentIndex = 0;

  bool _shuffle = false;
  LoopMode _loopMode = LoopMode.off;
  double _volume = 1.0;

  StreamSubscription<int?>? _indexSub;

  AudioProvider({required this.audioHandler, required this.storage}) {
    _init();
  }

  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong => _playlist.isEmpty ? null : _playlist[_currentIndex];

  bool get isShuffleEnabled => _shuffle;
  LoopMode get loopMode => _loopMode;
  double get volume => _volume;

  Stream<Duration> get positionStream => audioHandler.player.positionStream;
  Stream<Duration?> get durationStream => audioHandler.player.durationStream;
  Stream<bool> get playingStream => audioHandler.player.playingStream;

  Future<void> _init() async {
    _shuffle = await storage.getShuffleState();
    _loopMode = LoopMode.values[await storage.getRepeatMode()];
    _volume = await storage.getVolume();

    await audioHandler.setShuffleEnabled(_shuffle);
    await audioHandler.setLoopMode(_loopMode);
    await audioHandler.setVolume(_volume);

    _indexSub = audioHandler.player.currentIndexStream.listen((i) {
      if (i == null) return;
      _currentIndex = i;
      notifyListeners();
    });
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    notifyListeners();

    await audioHandler.setQueueAndPlay(songs, startIndex);
    await storage.saveLastPlayed(songs[startIndex].id);
  }

  Future<void> playPause() async {
    if (audioHandler.player.playing) {
      await audioHandler.pause();
    } else {
      await audioHandler.play();
    }
    notifyListeners();
  }

  Future<void> next() async => audioHandler.skipToNext();
  Future<void> previous() async => audioHandler.skipToPrevious();
  Future<void> seek(Duration p) async => audioHandler.seek(p);

  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    await audioHandler.setShuffleEnabled(_shuffle);
    await storage.saveShuffleState(_shuffle);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    await audioHandler.setLoopMode(_loopMode);
    await storage.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    _volume = v;
    await audioHandler.setVolume(v);
    await storage.saveVolume(v);
    notifyListeners();
  }

  @override
  void dispose() {
    _indexSub?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class AppAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  final List<SongModel> _songs = [];

  AppAudioHandler() {
    _init();
  }

  AudioPlayer get player => _player;

  Future<void> _init() async {
    await _player.setAudioSource(_playlist);

    _player.playbackEventStream.listen((event) {
      playbackState.add(_transformEvent(event));
    });

    _player.currentIndexStream.listen((index) {
      if (index == null) return;
      if (index < 0 || index >= _songs.length) return;
      mediaItem.add(_toMediaItem(_songs[index]));
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    final playing = _player.playing;

    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
      androidCompactActionIndices: const [0, 1, 3],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  MediaItem _toMediaItem(SongModel s) => MediaItem(
    id: s.id,
    title: s.title,
    artist: s.artist,
    album: s.album,
    duration: s.duration,
    artUri: (s.albumArt != null && s.albumArt!.isNotEmpty) ? Uri.parse(s.albumArt!) : null,
    extras: {
      'filePath': s.filePath,
      'albumArt': s.albumArt,
    },
  );

  Future<void> setQueueAndPlay(List<SongModel> songs, int startIndex) async {
    _songs
      ..clear()
      ..addAll(songs);

    final items = songs.map(_toMediaItem).toList();
    queue.add(items);

    final sources = songs.map((s) => AudioSource.uri(Uri.file(s.filePath))).toList();
    await _playlist.clear();
    await _playlist.addAll(sources);

    await _player.seek(Duration.zero, index: startIndex);
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);
  Future<void> setShuffleEnabled(bool enabled) => _player.setShuffleModeEnabled(enabled);
  Future<void> setVolume(double v) => _player.setVolume(v);


  Future<void> disposeHandler() async {
    await _player.dispose();
  }

}

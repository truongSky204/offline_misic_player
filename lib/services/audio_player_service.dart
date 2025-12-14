import 'package:just_audio/just_audio.dart';
import 'audio_handler.dart';

class AudioPlayerService {
  final AppAudioHandler handler;
  AudioPlayerService(this.handler);

  Stream<Duration> get positionStream => handler.player.positionStream;
  Stream<Duration?> get durationStream => handler.player.durationStream;
  Stream<bool> get playingStream => handler.player.playingStream;

  Duration get position => handler.player.position;
  Duration? get duration => handler.player.duration;
  bool get isPlaying => handler.player.playing;

  Future<void> play() => handler.play();
  Future<void> pause() => handler.pause();
  Future<void> stop() => handler.stop();
  Future<void> seek(Duration p) => handler.seek(p);
  Future<void> next() => handler.skipToNext();
  Future<void> previous() => handler.skipToPrevious();

  Future<void> setLoopMode(LoopMode mode) => handler.setLoopMode(mode);
  Future<void> setShuffle(bool enabled) => handler.setShuffleEnabled(enabled);
  Future<void> setVolume(double v) => handler.setVolume(v);
}

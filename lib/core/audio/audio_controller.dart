import 'package:flutter/foundation.dart';

/// The three independent audio channels. Keeping them separate is what stops
/// a voiceover from being drowned by background music or clipped by a rapid
/// burst of UI taps.
enum AudioChannel { bgm, voice, sfx }

extension AudioChannelMeta on AudioChannel {
  String get key => name;
  String get label {
    switch (this) {
      case AudioChannel.bgm:
        return 'Music';
      case AudioChannel.voice:
        return 'Voiceovers';
      case AudioChannel.sfx:
        return 'Sound Effects';
    }
  }
}

/// One channel's live state: volume, mute, and (for BGM/voice) the single
/// clip currently "playing". This is the anti-overlap guarantee - a channel
/// holds at most one active clip, so a new voiceover replaces the old one
/// instead of stacking on top of it.
class ChannelState {
  ChannelState({this.volume = 0.8, this.muted = false, this.nowPlaying});
  double volume;
  bool muted;
  String? nowPlaying;

  double get effectiveVolume => muted ? 0 : volume;
}

/// A pluggable sink so the controller stays testable and simulator-safe.
/// In production this is backed by just_audio / an AVAudioEngine mixer; the
/// default [LoggingAudioSink] just records intents so the demo needs no
/// bundled audio files and never lags an older device.
abstract class AudioSink {
  void play(AudioChannel channel, String clip, double volume, {bool loop = false});
  void stop(AudioChannel channel);
  void setVolume(AudioChannel channel, double volume);
}

class LoggingAudioSink implements AudioSink {
  final List<String> log = [];
  @override
  void play(AudioChannel channel, String clip, double volume, {bool loop = false}) {
    log.add('play ${channel.key} $clip vol=${volume.toStringAsFixed(2)} loop=$loop');
    if (kDebugMode) debugPrint('[audio] ${log.last}');
  }

  @override
  void stop(AudioChannel channel) => log.add('stop ${channel.key}');

  @override
  void setVolume(AudioChannel channel, double volume) =>
      log.add('vol ${channel.key} ${volume.toStringAsFixed(2)}');
}

/// Global audio controller - a strict 3-channel mixer.
///
/// - BGM loops and only ever runs one track.
/// - Voice replaces the currently playing voiceover (no overlap).
/// - SFX is fire-and-forget but volume-governed to avoid a lag storm.
class AudioController extends ChangeNotifier {
  AudioController({AudioSink? sink}) : _sink = sink ?? LoggingAudioSink();

  final AudioSink _sink;
  final Map<AudioChannel, ChannelState> channels = {
    AudioChannel.bgm: ChannelState(volume: 0.7),
    AudioChannel.voice: ChannelState(volume: 0.9),
    AudioChannel.sfx: ChannelState(volume: 0.6),
  };

  ChannelState state(AudioChannel c) => channels[c]!;

  void setVolume(AudioChannel c, double v) {
    state(c).volume = v.clamp(0, 1);
    _sink.setVolume(c, state(c).effectiveVolume);
    notifyListeners();
  }

  void setMuted(AudioChannel c, bool muted) {
    state(c).muted = muted;
    _sink.setVolume(c, state(c).effectiveVolume);
    notifyListeners();
  }

  void playBgm(String track) {
    final s = state(AudioChannel.bgm);
    if (s.nowPlaying == track) return;
    _sink.play(AudioChannel.bgm, track, s.effectiveVolume, loop: true);
    s.nowPlaying = track;
    notifyListeners();
  }

  /// Speaking a new line stops the previous one first - never overlaps.
  void playVoice(String clip) {
    final s = state(AudioChannel.voice);
    if (s.nowPlaying != null) _sink.stop(AudioChannel.voice);
    _sink.play(AudioChannel.voice, clip, s.effectiveVolume);
    s.nowPlaying = clip;
    notifyListeners();
  }

  void playSfx(String clip) {
    final s = state(AudioChannel.sfx);
    _sink.play(AudioChannel.sfx, clip, s.effectiveVolume);
  }

  void stopAll() {
    for (final c in AudioChannel.values) {
      _sink.stop(c);
      state(c).nowPlaying = null;
    }
    notifyListeners();
  }
}

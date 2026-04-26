import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';
import 'package:music_player_app/shared/audio/playback_state.dart';

class NowPlayingViewModel extends ChangeNotifier {
  NowPlayingViewModel(this._repository) {
    _stateSub = _repository.state.listen((s) {
      _state = s;
      notifyListeners();
    });
    _queueSub = _repository.queue.listen((q) {
      _queue = q;
      notifyListeners();
    });
  }

  final PlaybackRepository _repository;
  late final StreamSubscription _stateSub;
  late final StreamSubscription _queueSub;

  PlaybackState _state = PlaybackState.empty;
  Queue _queue = Queue.empty;

  PlaybackState get state => _state;
  Queue get queue => _queue;

  Future<void> pause() => _repository.pause();
  Future<void> resume() => _repository.resume();
  Future<void> skipNext() => _repository.skipNext();
  Future<void> skipPrevious() => _repository.skipPrevious();
  Future<void> seekTo(Duration position) => _repository.seekTo(position);
  Future<void> setVolume(double volume) => _repository.setVolume(volume);
  Future<void> setShuffle(bool enabled) => _repository.setShuffle(enabled);
  Future<void> setRepeatMode(RepeatMode mode) =>
      _repository.setRepeatMode(mode);

  @override
  void dispose() {
    _stateSub.cancel();
    _queueSub.cancel();
    super.dispose();
  }
}

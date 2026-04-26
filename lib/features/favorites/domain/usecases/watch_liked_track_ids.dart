import 'package:music_player_app/features/favorites/domain/repositories/favorites_repository.dart';

class WatchLikedTrackIds {
  WatchLikedTrackIds(this._repository);
  final FavoritesRepository _repository;

  Stream<Set<String>> call() => _repository.watchLikedTrackIds();
}

import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/playlists/domain/entities/playlist.dart';

abstract class PlaylistRepository {
  Stream<Either<Failure, List<Playlist>>> watchPlaylists();
  Stream<Either<Failure, Playlist>> watchPlaylist(String playlistId);
  Future<Either<Failure, Playlist>> create(String name);
  Future<Either<Failure, void>> rename(String playlistId, String newName);
  Future<Either<Failure, void>> delete(String playlistId);
  Future<Either<Failure, void>> addTrack(String playlistId, String trackId);
  Future<Either<Failure, void>> removeTrack(String playlistId, String trackId);
  Future<Either<Failure, void>> reorder(String playlistId, int from, int to);
}

import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';

class AlbumDetail {
  const AlbumDetail({required this.album, required this.tracks});
  final Album album;
  final List<Track> tracks;
}

class GetAlbumDetail {
  GetAlbumDetail(this._repository);
  final LibraryRepository _repository;

  Future<Either<Failure, AlbumDetail>> call(String albumId) async {
    final albumResult = await _repository.getAlbum(albumId);
    return albumResult.fold(
      Left.new,
      (album) async {
        final tracksResult = await _repository.getTracksOfAlbum(albumId);
        return tracksResult.fold(
          Left.new,
          (tracks) => Right(AlbumDetail(album: album, tracks: tracks)),
        );
      },
    );
  }
}

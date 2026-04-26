import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';

class ArtistDetail {
  const ArtistDetail({required this.artist, required this.albums});
  final Artist artist;
  final List<Album> albums;
}

class GetArtistDetail {
  GetArtistDetail(this._repository);
  final LibraryRepository _repository;

  Future<Either<Failure, ArtistDetail>> call(String artistId) async {
    final artistResult = await _repository.getArtist(artistId);
    return artistResult.fold(
      Left.new,
      (artist) async {
        final albumsResult = await _repository.getAlbumsOfArtist(artistId);
        return albumsResult.fold(
          Left.new,
          (albums) => Right(ArtistDetail(artist: artist, albums: albums)),
        );
      },
    );
  }
}

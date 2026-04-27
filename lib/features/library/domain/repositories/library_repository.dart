import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';

enum TrackSort { title, artist, album, recentlyAdded }

abstract class LibraryRepository {
  Stream<Either<Failure, List<Track>>> watchTracks({
    TrackSort sort = TrackSort.title,
  });
  Stream<Either<Failure, List<Album>>> watchAlbums();
  Stream<Either<Failure, List<Artist>>> watchArtists();

  Future<Either<Failure, Album>> getAlbum(String albumId);
  Future<Either<Failure, List<Track>>> getTracksOfAlbum(String albumId);
  Future<Either<Failure, Artist>> getArtist(String artistId);
  Future<Either<Failure, List<Album>>> getAlbumsOfArtist(String artistId);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/library/data/models/album_model.dart';
import 'package:music_player_app/features/library/data/models/artist_model.dart';
import 'package:music_player_app/features/library/data/models/track_model.dart';
import 'package:music_player_app/features/search/domain/entities/search_results.dart';

class SearchLocalDatasource {
  SearchLocalDatasource(this._db);
  final FirebaseFirestore _db;

  Stream<SearchResults> search(String query) {
    if (query.trim().isEmpty) {
      return Stream.value(const SearchResults());
    }
    final q = query.trim().toLowerCase();
    final end = '$q';

    final tracks = _db
        .collection('catalog/tracks/items')
        .where('titleLower', isGreaterThanOrEqualTo: q)
        .where('titleLower', isLessThan: end)
        .limit(20)
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) => TrackModel.fromFirestore(
                  d as DocumentSnapshot<Map<String, dynamic>>,
                ).toDomain(),
              )
              .toList(),
        );

    final albums = _db
        .collection('catalog/albums/items')
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThan: end)
        .limit(10)
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) => AlbumModel.fromFirestore(
                  d as DocumentSnapshot<Map<String, dynamic>>,
                ).toDomain(),
              )
              .toList(),
        );

    final artists = _db
        .collection('catalog/artists/items')
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThan: end)
        .limit(10)
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) => ArtistModel.fromFirestore(
                  d as DocumentSnapshot<Map<String, dynamic>>,
                ).toDomain(),
              )
              .toList(),
        );

    return tracks.asyncMap((t) async {
      final a = await albums.first;
      final ar = await artists.first;
      return SearchResults(tracks: t, albums: a, artists: ar);
    });
  }
}

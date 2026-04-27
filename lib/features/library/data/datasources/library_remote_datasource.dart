import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/library/data/models/album_model.dart';
import 'package:music_player_app/features/library/data/models/artist_model.dart';
import 'package:music_player_app/features/library/data/models/track_model.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';

class LibraryRemoteDatasource {
  LibraryRemoteDatasource(this._db);
  final FirebaseFirestore _db;

  Stream<List<TrackModel>> watchTracks({TrackSort sort = TrackSort.title}) {
    Query<Map<String, dynamic>> q = _db.collection('catalog/tracks/items');
    if (sort == TrackSort.title) q = q.orderBy('title');
    if (sort == TrackSort.artist) q = q.orderBy('artistName');
    return q.snapshots().map(
      (snap) =>
          snap.docs
              .map(
                (d) => TrackModel.fromFirestore(
                  d as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
    );
  }

  Stream<List<AlbumModel>> watchAlbums() => _db
      .collection('catalog/albums/items')
      .orderBy('title')
      .snapshots()
      .map(
        (snap) =>
            snap.docs
                .map(
                  (d) => AlbumModel.fromFirestore(
                    d as DocumentSnapshot<Map<String, dynamic>>,
                  ),
                )
                .toList(),
      );

  Stream<List<ArtistModel>> watchArtists() => _db
      .collection('catalog/artists/items')
      .orderBy('name')
      .snapshots()
      .map(
        (snap) =>
            snap.docs
                .map(
                  (d) => ArtistModel.fromFirestore(
                    d as DocumentSnapshot<Map<String, dynamic>>,
                  ),
                )
                .toList(),
      );

  Future<List<TrackModel>> getTracksOfAlbum(String albumId) async {
    final snap = await _db
        .collection('catalog/tracks/items')
        .where('albumId', isEqualTo: albumId)
        .get();
    return snap.docs
        .map(
          (d) => TrackModel.fromFirestore(
            d as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }
}

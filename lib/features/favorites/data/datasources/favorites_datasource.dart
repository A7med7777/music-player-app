import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/library/data/models/track_model.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';

class FavoritesDatasource {
  FavoritesDatasource(this._db, this._uid);
  final FirebaseFirestore _db;
  final String Function() _uid;

  CollectionReference<Map<String, dynamic>> get _likesRef =>
      _db.collection('users/${_uid()}/likes');

  Stream<List<Track>> watchFavorites() {
    return _likesRef
        .orderBy('likedAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final tracks = <Track>[];
          for (final doc in snap.docs) {
            try {
              final trackDoc = await _db
                  .doc('catalog/tracks/${doc.id}')
                  .get() as DocumentSnapshot<Map<String, dynamic>>;
              if (trackDoc.exists) {
                tracks.add(TrackModel.fromFirestore(trackDoc).toDomain());
              }
            } catch (_) {
              // Skip unavailable tracks silently
            }
          }
          return tracks;
        });
  }

  Stream<Set<String>> watchLikedTrackIds() => _likesRef
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.id).toSet());

  Future<void> like(String trackId) async {
    await _likesRef.doc(trackId).set({
      'likedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unlike(String trackId) async {
    await _likesRef.doc(trackId).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/playlists/data/models/playlist_model.dart';
import 'package:uuid/uuid.dart';

// UUID is available transitively via firebase packages.
// If not, add uuid: ^4.4.0 to pubspec.yaml.

class PlaylistDatasource {
  PlaylistDatasource(this._db, this._uid);
  final FirebaseFirestore _db;
  final String Function() _uid;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('users/${_uid()}/playlists');

  Stream<List<PlaylistModel>> watchPlaylists() => _ref
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map(
              (d) => PlaylistModel.fromFirestore(
                d as DocumentSnapshot<Map<String, dynamic>>,
                _uid(),
              ),
            )
            .toList(),
      );

  Stream<PlaylistModel?> watchPlaylist(String id) =>
      _ref.doc(id).snapshots().map(
        (doc) => doc.exists
            ? PlaylistModel.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>,
                _uid(),
              )
            : null,
      );

  Future<PlaylistModel> create(String name) async {
    final now = DateTime.now().toUtc();
    final id = const Uuid().v4();
    final model = PlaylistModel(
      id: id,
      ownerUid: _uid(),
      name: name,
      trackIds: const [],
      createdAt: now,
      updatedAt: now,
    );
    await _ref.doc(id).set(model.toFirestore());
    return model;
  }

  Future<void> rename(String playlistId, String newName) async {
    await _ref.doc(playlistId).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String playlistId) async {
    await _ref.doc(playlistId).delete();
  }

  Future<void> addTrack(String playlistId, String trackId) async {
    await _ref.doc(playlistId).update({
      'trackIds': FieldValue.arrayUnion([trackId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    await _ref.doc(playlistId).update({
      'trackIds': FieldValue.arrayRemove([trackId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reorder(String playlistId, int from, int to) async {
    final doc = await _ref.doc(playlistId).get();
    final ids = List<String>.from(doc.data()?['trackIds'] as List? ?? []);
    if (from < 0 || from >= ids.length || to < 0 || to >= ids.length) return;
    final item = ids.removeAt(from);
    ids.insert(to, item);
    await _ref.doc(playlistId).update({
      'trackIds': ids,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

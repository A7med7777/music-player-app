import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/search/domain/entities/search_results.dart';

class SearchHistoryDatasource {
  SearchHistoryDatasource(this._db, this._uid);
  final FirebaseFirestore _db;
  final String Function() _uid;

  static const _maxHistory = 20;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('users/${_uid()}/searchHistory');

  Future<List<SearchQuery>> getRecentQueries({int limit = 20}) async {
    final snap = await _ref
        .orderBy('lastUsedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return SearchQuery(
        query: data['query'] as String,
        lastUsedAt: (data['lastUsedAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<void> recordQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final docId = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    await _ref.doc(docId).set({
      'query': trimmed,
      'lastUsedAt': FieldValue.serverTimestamp(),
    });
    await _evictOldest();
  }

  Future<void> clearAll() async {
    final snap = await _ref.get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _evictOldest() async {
    final snap = await _ref.orderBy('lastUsedAt', descending: false).get();
    if (snap.docs.length <= _maxHistory) return;
    final toDelete = snap.docs.length - _maxHistory;
    final batch = _db.batch();
    for (int i = 0; i < toDelete; i++) {
      batch.delete(snap.docs[i].reference);
    }
    await batch.commit();
  }
}

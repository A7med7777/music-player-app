import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';
import 'package:music_player_app/features/search/domain/entities/search_results.dart';
import 'package:music_player_app/features/search/domain/usecases/clear_recent_queries.dart';
import 'package:music_player_app/features/search/domain/usecases/get_recent_queries.dart';
import 'package:music_player_app/features/search/domain/usecases/record_query.dart';
import 'package:music_player_app/features/search/domain/usecases/search_catalog.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required SearchCatalog searchCatalog,
    required GetRecentQueries getRecentQueries,
    required RecordQuery recordQuery,
    required ClearRecentQueries clearRecentQueries,
    required PlaybackRepository playbackRepository,
  })  : _searchCatalog = searchCatalog,
        _getRecentQueries = getRecentQueries,
        _recordQuery = recordQuery,
        _clearRecentQueries = clearRecentQueries,
        _playback = playbackRepository {
    loadRecentQueries();
  }

  final SearchCatalog _searchCatalog;
  final GetRecentQueries _getRecentQueries;
  final RecordQuery _recordQuery;
  final ClearRecentQueries _clearRecentQueries;
  final PlaybackRepository _playback;

  String _query = '';
  SearchResults? results;
  List<SearchQuery> recentQueries = [];
  bool loading = false;
  Failure? failure;

  StreamSubscription? _searchSub;
  Timer? _debounce;

  String get query => _query;
  bool get hasQuery => _query.trim().isNotEmpty;

  void onQueryChanged(String q) {
    _query = q;
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      results = null;
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    _debounce = Timer(const Duration(milliseconds: 150), _doSearch);
  }

  void _doSearch() {
    _searchSub?.cancel();
    _searchSub = _searchCatalog(_query).listen((result) {
      result.fold((f) => failure = f, (r) {
        results = r;
        failure = null;
      });
      loading = false;
      notifyListeners();
    });
  }

  Future<void> loadRecentQueries() async {
    final result = await _getRecentQueries();
    result.fold((_) {}, (q) => recentQueries = q);
    notifyListeners();
  }

  Future<void> clearRecent() async {
    await _clearRecentQueries();
    recentQueries = [];
    notifyListeners();
  }

  Future<void> playTrack(String trackId) async {
    if (_query.trim().isNotEmpty) {
      await _recordQuery(_query.trim());
      await loadRecentQueries();
    }
    await _playback.playTrack(trackId);
  }

  @override
  void dispose() {
    _searchSub?.cancel();
    _debounce?.cancel();
    super.dispose();
  }
}

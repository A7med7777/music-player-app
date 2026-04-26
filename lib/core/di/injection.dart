import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:music_player_app/features/favorites/data/datasources/favorites_datasource.dart';
import 'package:music_player_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:music_player_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player_app/features/favorites/domain/usecases/like_track.dart';
import 'package:music_player_app/features/favorites/domain/usecases/play_all_liked.dart';
import 'package:music_player_app/features/favorites/domain/usecases/unlike_track.dart';
import 'package:music_player_app/features/favorites/domain/usecases/watch_favorites.dart';
import 'package:music_player_app/features/favorites/domain/usecases/watch_liked_track_ids.dart';
import 'package:music_player_app/features/favorites/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:music_player_app/features/library/data/datasources/library_remote_datasource.dart';
import 'package:music_player_app/features/library/data/repositories/library_repository_impl.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';
import 'package:music_player_app/features/library/domain/usecases/get_albums.dart';
import 'package:music_player_app/features/library/domain/usecases/get_artists.dart';
import 'package:music_player_app/features/library/domain/usecases/get_tracks.dart';
import 'package:music_player_app/features/library/presentation/viewmodels/library_viewmodel.dart';
import 'package:music_player_app/features/now_playing/data/repositories/playback_repository_impl.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';
import 'package:music_player_app/features/now_playing/presentation/viewmodels/now_playing_viewmodel.dart';
import 'package:music_player_app/features/playlists/data/datasources/playlist_datasource.dart';
import 'package:music_player_app/features/playlists/data/repositories/playlist_repository_impl.dart';
import 'package:music_player_app/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:music_player_app/features/playlists/domain/usecases/add_track_to_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/create_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/delete_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/play_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/remove_track_from_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/rename_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/reorder_playlist_tracks.dart';
import 'package:music_player_app/features/playlists/domain/usecases/watch_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/watch_playlists.dart';
import 'package:music_player_app/features/playlists/presentation/viewmodels/playlist_detail_viewmodel.dart';
import 'package:music_player_app/features/playlists/presentation/viewmodels/playlists_viewmodel.dart';
import 'package:music_player_app/features/profile/data/datasources/firebase_auth_datasource.dart';
import 'package:music_player_app/features/profile/data/datasources/profile_datasource.dart';
import 'package:music_player_app/features/profile/data/repositories/auth_repository_impl.dart';
import 'package:music_player_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:music_player_app/features/profile/data/repositories/settings_repository_impl.dart';
import 'package:music_player_app/features/profile/domain/repositories/auth_repository.dart';
import 'package:music_player_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_player_app/features/profile/domain/repositories/settings_repository.dart';
import 'package:music_player_app/features/profile/domain/usecases/set_theme.dart';
import 'package:music_player_app/features/profile/domain/usecases/update_avatar.dart';
import 'package:music_player_app/features/profile/domain/usecases/update_display_name.dart';
import 'package:music_player_app/features/profile/domain/usecases/watch_profile.dart';
import 'package:music_player_app/features/profile/domain/usecases/watch_profile_summary.dart';
import 'package:music_player_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:music_player_app/features/profile/presentation/viewmodels/settings_viewmodel.dart';
import 'package:music_player_app/features/search/data/datasources/search_history_datasource.dart';
import 'package:music_player_app/features/search/data/datasources/search_local_datasource.dart';
import 'package:music_player_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:music_player_app/features/search/domain/repositories/search_repository.dart';
import 'package:music_player_app/features/search/domain/usecases/clear_recent_queries.dart';
import 'package:music_player_app/features/search/domain/usecases/get_recent_queries.dart';
import 'package:music_player_app/features/search/domain/usecases/record_query.dart';
import 'package:music_player_app/features/search/domain/usecases/search_catalog.dart';
import 'package:music_player_app/features/search/presentation/viewmodels/search_viewmodel.dart';
import 'package:music_player_app/shared/audio/audio_handler.dart';
import 'package:music_player_app/shared/audio/playback_controller.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // Auth datasource — provides uid() lambda used by all user-scoped repos
  final authDs = FirebaseAuthDatasource(auth);
  sl.registerSingleton<FirebaseAuthDatasource>(authDs);

  String uid() => authDs.currentUid ?? 'anonymous';

  final authRepo = AuthRepositoryImpl(authDs);
  sl.registerSingleton<AuthRepository>(authRepo);

  // Audio
  final handler = await AudioService.init(
    builder: MusicAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_player_app.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
    ),
  );
  sl.registerSingleton<MusicAudioHandler>(handler);

  final controller = PlaybackController(handler);
  await controller.initialize();
  sl.registerSingleton<PlaybackController>(controller);

  final playbackRepo = PlaybackRepositoryImpl(controller, db, uid);
  sl.registerSingleton<PlaybackRepository>(playbackRepo);
  sl.registerSingleton<NowPlayingViewModel>(NowPlayingViewModel(playbackRepo));

  // Settings
  final settingsRepo = SettingsRepositoryImpl(db, uid);
  sl.registerSingleton<SettingsRepository>(settingsRepo);
  sl.registerSingleton<SettingsViewModel>(SettingsViewModel(settingsRepo));

  // Library
  final libraryDs = LibraryRemoteDatasource(db);
  final libraryRepo = LibraryRepositoryImpl(libraryDs);
  sl.registerSingleton<LibraryRepository>(libraryRepo);

  final getTracks = GetTracks(libraryRepo);
  final getAlbums = GetAlbums(libraryRepo);
  final getArtists = GetArtists(libraryRepo);
  sl.registerSingleton<LibraryViewModel>(
    LibraryViewModel(
      getTracks: getTracks,
      getAlbums: getAlbums,
      getArtists: getArtists,
      playbackRepository: playbackRepo,
    ),
  );

  // Favorites
  final favDs = FavoritesDatasource(db, uid);
  final favRepo = FavoritesRepositoryImpl(favDs);
  sl.registerSingleton<FavoritesRepository>(favRepo);

  final likeTrack = LikeTrack(favRepo);
  final unlikeTrack = UnlikeTrack(favRepo);
  sl.registerSingleton<FavoritesViewModel>(
    FavoritesViewModel(
      favoritesRepository: favRepo,
      likeTrack: likeTrack,
      unlikeTrack: unlikeTrack,
      playbackRepository: playbackRepo,
    ),
  );
  sl.registerSingleton<WatchFavorites>(WatchFavorites(favRepo));
  sl.registerSingleton<WatchLikedTrackIds>(WatchLikedTrackIds(favRepo));
  sl.registerSingleton<PlayAllLiked>(PlayAllLiked(playbackRepo));

  // Search
  final searchDs = SearchLocalDatasource(db);
  final searchHistoryDs = SearchHistoryDatasource(db, uid);
  final searchRepo = SearchRepositoryImpl(searchDs, searchHistoryDs);
  sl.registerSingleton<SearchRepository>(searchRepo);
  sl.registerSingleton<SearchViewModel>(
    SearchViewModel(
      searchCatalog: SearchCatalog(searchRepo),
      getRecentQueries: GetRecentQueries(searchRepo),
      recordQuery: RecordQuery(searchRepo),
      clearRecentQueries: ClearRecentQueries(searchRepo),
      playbackRepository: playbackRepo,
    ),
  );

  // Playlists
  final playlistDs = PlaylistDatasource(db, uid);
  final playlistRepo = PlaylistRepositoryImpl(playlistDs);
  sl.registerSingleton<PlaylistRepository>(playlistRepo);
  sl.registerSingleton<PlaylistsViewModel>(
    PlaylistsViewModel(
      watchPlaylists: WatchPlaylists(playlistRepo),
      createPlaylist: CreatePlaylist(playlistRepo),
      renamePlaylist: RenamePlaylist(playlistRepo),
      deletePlaylist: DeletePlaylist(playlistRepo),
    ),
  );

  // Playlist detail factory — created per route, registered as factory
  sl.registerFactory<PlaylistDetailViewModel>(
    () => PlaylistDetailViewModel(
      playlistId: '',
      watchPlaylist: WatchPlaylist(playlistRepo),
      addTrack: AddTrackToPlaylist(playlistRepo),
      removeTrack: RemoveTrackFromPlaylist(playlistRepo),
      reorderTracks: ReorderPlaylistTracks(playlistRepo),
      playPlaylist: PlayPlaylist(playbackRepo),
    ),
  );

  // Profile
  final profileDs = ProfileDatasource(db, uid);
  final profileRepo = ProfileRepositoryImpl(profileDs);
  sl.registerSingleton<ProfileRepository>(profileRepo);
  sl.registerSingleton<ProfileViewModel>(
    ProfileViewModel(
      watchProfile: WatchProfile(profileRepo),
      watchSummary: WatchProfileSummary(profileRepo),
      updateDisplayName: UpdateDisplayName(profileRepo),
      updateAvatar: UpdateAvatar(profileRepo),
    ),
  );

  // Stand-alone use cases used in multiple features
  sl.registerSingleton<SetTheme>(SetTheme(settingsRepo));
  sl.registerSingleton<AddTrackToPlaylist>(AddTrackToPlaylist(playlistRepo));
}

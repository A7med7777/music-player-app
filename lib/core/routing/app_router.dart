import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/di/injection.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';
import 'package:music_player_app/features/library/presentation/views/album_detail_screen.dart';
import 'package:music_player_app/features/library/presentation/views/artist_detail_screen.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';
import 'package:music_player_app/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:music_player_app/features/playlists/domain/usecases/add_track_to_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/play_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/remove_track_from_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/reorder_playlist_tracks.dart';
import 'package:music_player_app/features/playlists/domain/usecases/watch_playlist.dart';
import 'package:music_player_app/features/playlists/presentation/viewmodels/playlist_detail_viewmodel.dart';
import 'package:music_player_app/shared/navigation/app_shell.dart';
import 'package:music_player_app/features/library/presentation/views/library_screen.dart';
import 'package:music_player_app/features/now_playing/presentation/views/now_playing_screen.dart';
import 'package:music_player_app/features/search/presentation/views/search_screen.dart';
import 'package:music_player_app/features/favorites/presentation/views/favorites_screen.dart';
import 'package:music_player_app/features/playlists/presentation/views/playlists_screen.dart';
import 'package:music_player_app/features/playlists/presentation/views/playlist_detail_screen.dart';
import 'package:music_player_app/features/profile/presentation/views/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: '/library',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (_, __) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'album/:albumId',
                  builder: (context, state) => AlbumDetailScreen(
                    album: state.extra as Album,
                  ),
                ),
                GoRoute(
                  path: 'artist/:artistId',
                  builder: (context, state) => ArtistDetailScreen(
                    artist: state.extra as Artist,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (_, __) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (_, __) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/playlists',
              builder: (_, __) => const PlaylistsScreen(),
              routes: [
                GoRoute(
                  path: ':playlistId',
                  builder: (context, state) {
                    final playlistId = state.pathParameters['playlistId']!;
                    return ChangeNotifierProvider(
                      create: (_) => PlaylistDetailViewModel(
                        playlistId: playlistId,
                        watchPlaylist:
                            WatchPlaylist(sl<PlaylistRepository>()),
                        addTrack:
                            AddTrackToPlaylist(sl<PlaylistRepository>()),
                        removeTrack:
                            RemoveTrackFromPlaylist(sl<PlaylistRepository>()),
                        reorderTracks:
                            ReorderPlaylistTracks(sl<PlaylistRepository>()),
                        playPlaylist: PlayPlaylist(sl<PlaybackRepository>()),
                      ),
                      child: PlaylistDetailScreen(playlistId: playlistId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/now-playing',
      parentNavigatorKey: _rootNavKey,
      builder: (_, __) => const NowPlayingScreen(),
    ),
  ],
);

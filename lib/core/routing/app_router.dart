import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      builder: (context, state, shell) =>
          AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (_, __) => const LibraryScreen(),
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
                  builder: (context, state) => PlaylistDetailScreen(
                    playlistId: state.pathParameters['playlistId']!,
                  ),
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

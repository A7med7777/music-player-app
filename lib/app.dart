import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/di/injection.dart';
import 'package:music_player_app/core/routing/app_router.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/favorites/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:music_player_app/features/library/presentation/viewmodels/library_viewmodel.dart';
import 'package:music_player_app/features/now_playing/presentation/viewmodels/now_playing_viewmodel.dart';
import 'package:music_player_app/features/playlists/presentation/viewmodels/playlists_viewmodel.dart';
import 'package:music_player_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:music_player_app/features/profile/presentation/viewmodels/settings_viewmodel.dart';
import 'package:music_player_app/features/search/presentation/viewmodels/search_viewmodel.dart';

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<SettingsViewModel>()),
        ChangeNotifierProvider.value(value: sl<NowPlayingViewModel>()),
        ChangeNotifierProvider.value(value: sl<LibraryViewModel>()),
        ChangeNotifierProvider.value(value: sl<FavoritesViewModel>()),
        ChangeNotifierProvider.value(value: sl<SearchViewModel>()),
        ChangeNotifierProvider.value(value: sl<PlaylistsViewModel>()),
        ChangeNotifierProvider.value(value: sl<ProfileViewModel>()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (_, settingsVm, __) => MaterialApp.router(
          title: 'Music Player',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: settingsVm.themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}

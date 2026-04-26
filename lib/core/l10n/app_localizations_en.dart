// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Music Player';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navProfile => 'Profile';

  @override
  String get libraryTabSongs => 'Songs';

  @override
  String get libraryTabAlbums => 'Albums';

  @override
  String get libraryTabArtists => 'Artists';

  @override
  String get libraryEmpty => 'No music found. Add audio files to get started.';

  @override
  String get nowPlayingTitle => 'Now Playing';

  @override
  String get nowPlayingQueue => 'Queue';

  @override
  String get nowPlayingNoTrack => 'Nothing playing';

  @override
  String get searchHint => 'Search songs, albums, artists…';

  @override
  String get searchSectionSongs => 'Songs';

  @override
  String get searchSectionAlbums => 'Albums';

  @override
  String get searchSectionArtists => 'Artists';

  @override
  String get searchSectionPlaylists => 'Playlists';

  @override
  String searchEmpty(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchRecentTitle => 'Recent Searches';

  @override
  String get searchClearRecent => 'Clear';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'You haven\'t liked any tracks yet.';

  @override
  String get favoritesPlayAll => 'Play All';

  @override
  String get favoritesShuffle => 'Shuffle';

  @override
  String get playlistsTitle => 'Playlists';

  @override
  String get playlistsEmpty => 'No playlists yet. Create one to get started.';

  @override
  String get playlistsCreate => 'New Playlist';

  @override
  String get playlistsCreateHint => 'Playlist name';

  @override
  String get playlistsRename => 'Rename';

  @override
  String get playlistsDelete => 'Delete';

  @override
  String playlistsDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get playlistsAddTrack => 'Add to Playlist';

  @override
  String get playlistsNewPlaylist => 'New Playlist';

  @override
  String get playlistsPlay => 'Play';

  @override
  String get playlistsShuffle => 'Shuffle';

  @override
  String playlistsTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDisplayName => 'Display Name';

  @override
  String profileTotalTracks(int count) {
    return '$count tracks';
  }

  @override
  String profileTotalLiked(int count) {
    return '$count liked';
  }

  @override
  String profileTotalPlaylists(int count) {
    return '$count playlists';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAudioQuality => 'Audio Quality';

  @override
  String get settingsAudioQualityAuto => 'Auto';

  @override
  String get settingsAudioQualityLow => 'Low';

  @override
  String get settingsAudioQualityNormal => 'Normal';

  @override
  String get settingsAudioQualityHigh => 'High';

  @override
  String get settingsCrossfade => 'Crossfade';

  @override
  String get settingsCrossfadeOff => 'Off';

  @override
  String get settingsEqualizer => 'Equalizer Preset';

  @override
  String get settingsShowExplicit => 'Show Explicit Content';

  @override
  String get settingsSpotify => 'Spotify';

  @override
  String get settingsSpotifyConnect => 'Connect to Spotify';

  @override
  String get settingsSpotifyConnected => 'Connected';

  @override
  String get settingsSpotifyDisconnect => 'Disconnect';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionSkipNext => 'Skip Next';

  @override
  String get actionSkipPrevious => 'Skip Previous';

  @override
  String get actionShuffle => 'Shuffle';

  @override
  String get actionRepeat => 'Repeat';

  @override
  String get actionLike => 'Like';

  @override
  String get actionUnlike => 'Unlike';

  @override
  String get actionAddToPlaylist => 'Add to Playlist';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionSave => 'Save';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorPlayback => 'Playback error. Skipping to next track.';

  @override
  String get errorTrackUnavailable => 'Track unavailable offline.';

  @override
  String get offlineBanner =>
      'You\'re offline. Some features may be unavailable.';

  @override
  String get loadingLabel => 'Loading…';

  @override
  String get spotifyBadge => 'Spotify';

  @override
  String get spotifyOffline => 'Spotify unavailable offline';
}

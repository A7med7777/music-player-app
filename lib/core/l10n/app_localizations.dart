import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Music Player'**
  String get appName;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @libraryTabSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get libraryTabSongs;

  /// No description provided for @libraryTabAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get libraryTabAlbums;

  /// No description provided for @libraryTabArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get libraryTabArtists;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No music found. Add audio files to get started.'**
  String get libraryEmpty;

  /// No description provided for @nowPlayingTitle.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlayingTitle;

  /// No description provided for @nowPlayingQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get nowPlayingQueue;

  /// No description provided for @nowPlayingNoTrack.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get nowPlayingNoTrack;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs, albums, artists…'**
  String get searchHint;

  /// No description provided for @searchSectionSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get searchSectionSongs;

  /// No description provided for @searchSectionAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get searchSectionAlbums;

  /// No description provided for @searchSectionArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get searchSectionArtists;

  /// No description provided for @searchSectionPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get searchSectionPlaylists;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchEmpty(String query);

  /// No description provided for @searchRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get searchRecentTitle;

  /// No description provided for @searchClearRecent.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearRecent;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t liked any tracks yet.'**
  String get favoritesEmpty;

  /// No description provided for @favoritesPlayAll.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get favoritesPlayAll;

  /// No description provided for @favoritesShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get favoritesShuffle;

  /// No description provided for @playlistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlistsTitle;

  /// No description provided for @playlistsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet. Create one to get started.'**
  String get playlistsEmpty;

  /// No description provided for @playlistsCreate.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get playlistsCreate;

  /// No description provided for @playlistsCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistsCreateHint;

  /// No description provided for @playlistsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get playlistsRename;

  /// No description provided for @playlistsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get playlistsDelete;

  /// No description provided for @playlistsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String playlistsDeleteConfirm(String name);

  /// No description provided for @playlistsAddTrack.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get playlistsAddTrack;

  /// No description provided for @playlistsNewPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get playlistsNewPlaylist;

  /// No description provided for @playlistsPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playlistsPlay;

  /// No description provided for @playlistsShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get playlistsShuffle;

  /// No description provided for @playlistsTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song} other{{count} songs}}'**
  String playlistsTrackCount(int count);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayName;

  /// No description provided for @profileTotalTracks.
  ///
  /// In en, this message translates to:
  /// **'{count} tracks'**
  String profileTotalTracks(int count);

  /// No description provided for @profileTotalLiked.
  ///
  /// In en, this message translates to:
  /// **'{count} liked'**
  String profileTotalLiked(int count);

  /// No description provided for @profileTotalPlaylists.
  ///
  /// In en, this message translates to:
  /// **'{count} playlists'**
  String profileTotalPlaylists(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsAudioQuality.
  ///
  /// In en, this message translates to:
  /// **'Audio Quality'**
  String get settingsAudioQuality;

  /// No description provided for @settingsAudioQualityAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsAudioQualityAuto;

  /// No description provided for @settingsAudioQualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get settingsAudioQualityLow;

  /// No description provided for @settingsAudioQualityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsAudioQualityNormal;

  /// No description provided for @settingsAudioQualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get settingsAudioQualityHigh;

  /// No description provided for @settingsCrossfade.
  ///
  /// In en, this message translates to:
  /// **'Crossfade'**
  String get settingsCrossfade;

  /// No description provided for @settingsCrossfadeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsCrossfadeOff;

  /// No description provided for @settingsEqualizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer Preset'**
  String get settingsEqualizer;

  /// No description provided for @settingsShowExplicit.
  ///
  /// In en, this message translates to:
  /// **'Show Explicit Content'**
  String get settingsShowExplicit;

  /// No description provided for @settingsSpotify.
  ///
  /// In en, this message translates to:
  /// **'Spotify'**
  String get settingsSpotify;

  /// No description provided for @settingsSpotifyConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect to Spotify'**
  String get settingsSpotifyConnect;

  /// No description provided for @settingsSpotifyConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get settingsSpotifyConnected;

  /// No description provided for @settingsSpotifyDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get settingsSpotifyDisconnect;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// No description provided for @actionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// No description provided for @actionSkipNext.
  ///
  /// In en, this message translates to:
  /// **'Skip Next'**
  String get actionSkipNext;

  /// No description provided for @actionSkipPrevious.
  ///
  /// In en, this message translates to:
  /// **'Skip Previous'**
  String get actionSkipPrevious;

  /// No description provided for @actionShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get actionShuffle;

  /// No description provided for @actionRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get actionRepeat;

  /// No description provided for @actionLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get actionLike;

  /// No description provided for @actionUnlike.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get actionUnlike;

  /// No description provided for @actionAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get actionAddToPlaylist;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback error. Skipping to next track.'**
  String get errorPlayback;

  /// No description provided for @errorTrackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Track unavailable offline.'**
  String get errorTrackUnavailable;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Some features may be unavailable.'**
  String get offlineBanner;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingLabel;

  /// No description provided for @spotifyBadge.
  ///
  /// In en, this message translates to:
  /// **'Spotify'**
  String get spotifyBadge;

  /// No description provided for @spotifyOffline.
  ///
  /// In en, this message translates to:
  /// **'Spotify unavailable offline'**
  String get spotifyOffline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

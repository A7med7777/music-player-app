// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Reproductor de Música';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navPlaylists => 'Listas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get libraryTabSongs => 'Canciones';

  @override
  String get libraryTabAlbums => 'Álbumes';

  @override
  String get libraryTabArtists => 'Artistas';

  @override
  String get libraryEmpty =>
      'No se encontró música. Agrega archivos de audio para comenzar.';

  @override
  String get nowPlayingTitle => 'Reproduciendo';

  @override
  String get nowPlayingQueue => 'Cola';

  @override
  String get nowPlayingNoTrack => 'Nada reproduciéndose';

  @override
  String get searchHint => 'Buscar canciones, álbumes, artistas…';

  @override
  String get searchSectionSongs => 'Canciones';

  @override
  String get searchSectionAlbums => 'Álbumes';

  @override
  String get searchSectionArtists => 'Artistas';

  @override
  String get searchSectionPlaylists => 'Listas';

  @override
  String searchEmpty(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get searchRecentTitle => 'Búsquedas recientes';

  @override
  String get searchClearRecent => 'Borrar';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesEmpty => 'Aún no tienes canciones favoritas.';

  @override
  String get favoritesPlayAll => 'Reproducir todo';

  @override
  String get favoritesShuffle => 'Aleatorio';

  @override
  String get playlistsTitle => 'Listas de reproducción';

  @override
  String get playlistsEmpty => 'Sin listas. Crea una para empezar.';

  @override
  String get playlistsCreate => 'Nueva lista';

  @override
  String get playlistsCreateHint => 'Nombre de la lista';

  @override
  String get playlistsRename => 'Renombrar';

  @override
  String get playlistsDelete => 'Eliminar';

  @override
  String playlistsDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get playlistsAddTrack => 'Agregar a lista';

  @override
  String get playlistsNewPlaylist => 'Nueva lista';

  @override
  String get playlistsPlay => 'Reproducir';

  @override
  String get playlistsShuffle => 'Aleatorio';

  @override
  String playlistsTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileDisplayName => 'Nombre';

  @override
  String profileTotalTracks(int count) {
    return '$count canciones';
  }

  @override
  String profileTotalLiked(int count) {
    return '$count favoritas';
  }

  @override
  String profileTotalPlaylists(int count) {
    return '$count listas';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsAudioQuality => 'Calidad de audio';

  @override
  String get settingsAudioQualityAuto => 'Automático';

  @override
  String get settingsAudioQualityLow => 'Baja';

  @override
  String get settingsAudioQualityNormal => 'Normal';

  @override
  String get settingsAudioQualityHigh => 'Alta';

  @override
  String get settingsCrossfade => 'Crossfade';

  @override
  String get settingsCrossfadeOff => 'Apagado';

  @override
  String get settingsEqualizer => 'Preset de ecualizador';

  @override
  String get settingsShowExplicit => 'Mostrar contenido explícito';

  @override
  String get settingsSpotify => 'Spotify';

  @override
  String get settingsSpotifyConnect => 'Conectar con Spotify';

  @override
  String get settingsSpotifyConnected => 'Conectado';

  @override
  String get settingsSpotifyDisconnect => 'Desconectar';

  @override
  String get actionPlay => 'Reproducir';

  @override
  String get actionPause => 'Pausar';

  @override
  String get actionSkipNext => 'Siguiente';

  @override
  String get actionSkipPrevious => 'Anterior';

  @override
  String get actionShuffle => 'Aleatorio';

  @override
  String get actionRepeat => 'Repetir';

  @override
  String get actionLike => 'Me gusta';

  @override
  String get actionUnlike => 'Quitar me gusta';

  @override
  String get actionAddToPlaylist => 'Agregar a lista';

  @override
  String get actionRemove => 'Eliminar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get errorGeneric => 'Algo salió mal. Por favor intenta de nuevo.';

  @override
  String get errorNetwork => 'Sin conexión a internet.';

  @override
  String get errorNotFound => 'No encontrado.';

  @override
  String get errorPlayback =>
      'Error de reproducción. Saltando a la siguiente canción.';

  @override
  String get errorTrackUnavailable => 'Canción no disponible sin conexión.';

  @override
  String get offlineBanner =>
      'Estás sin conexión. Algunas funciones pueden no estar disponibles.';

  @override
  String get loadingLabel => 'Cargando…';

  @override
  String get spotifyBadge => 'Spotify';

  @override
  String get spotifyOffline => 'Spotify no disponible sin conexión';
}

import 'package:flutter/material.dart';

class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.colorPrimary,
    required this.colorOnPrimary,
    required this.colorSurface,
    required this.colorOnSurface,
    required this.colorSurfaceVariant,
    required this.colorOnSurfaceVariant,
    required this.colorOutline,
    required this.colorError,
    required this.colorMiniPlayer,
    required this.colorFocusRing,
    required this.spacing4,
    required this.spacing8,
    required this.spacing12,
    required this.spacing16,
    required this.spacing24,
    required this.spacing32,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.radiusCircular,
    required this.durationFast,
    required this.durationNormal,
    required this.durationSlow,
    required this.artworkSizeMini,
    required this.artworkSizeCard,
    required this.artworkSizeFull,
  });

  final Color colorPrimary;
  final Color colorOnPrimary;
  final Color colorSurface;
  final Color colorOnSurface;
  final Color colorSurfaceVariant;
  final Color colorOnSurfaceVariant;
  final Color colorOutline;
  final Color colorError;
  final Color colorMiniPlayer;
  final Color colorFocusRing;

  final double spacing4;
  final double spacing8;
  final double spacing12;
  final double spacing16;
  final double spacing24;
  final double spacing32;

  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double radiusCircular;

  final Duration durationFast;
  final Duration durationNormal;
  final Duration durationSlow;

  final double artworkSizeMini;
  final double artworkSizeCard;
  final double artworkSizeFull;

  static final light = AppTokens(
    colorPrimary: const Color(0xFF6750A4),
    colorOnPrimary: Colors.white,
    colorSurface: const Color(0xFFFFFBFE),
    colorOnSurface: const Color(0xFF1C1B1F),
    colorSurfaceVariant: const Color(0xFFE7E0EC),
    colorOnSurfaceVariant: const Color(0xFF49454F),
    colorOutline: const Color(0xFF79747E),
    colorError: const Color(0xFFB3261E),
    colorMiniPlayer: const Color(0xFFF3EDF7),
    colorFocusRing: const Color(0xFF6750A4),
    spacing4: 4,
    spacing8: 8,
    spacing12: 12,
    spacing16: 16,
    spacing24: 24,
    spacing32: 32,
    radiusSmall: 4,
    radiusMedium: 12,
    radiusLarge: 16,
    radiusCircular: 9999,
    durationFast: const Duration(milliseconds: 150),
    durationNormal: const Duration(milliseconds: 250),
    durationSlow: const Duration(milliseconds: 400),
    artworkSizeMini: 40,
    artworkSizeCard: 56,
    artworkSizeFull: 280,
  );

  static final dark = AppTokens(
    colorPrimary: const Color(0xFFD0BCFF),
    colorOnPrimary: const Color(0xFF381E72),
    colorSurface: const Color(0xFF1C1B1F),
    colorOnSurface: const Color(0xFFE6E1E5),
    colorSurfaceVariant: const Color(0xFF49454F),
    colorOnSurfaceVariant: const Color(0xFFCAC4D0),
    colorOutline: const Color(0xFF938F99),
    colorError: const Color(0xFFF2B8B5),
    colorMiniPlayer: const Color(0xFF2B2930),
    colorFocusRing: const Color(0xFFD0BCFF),
    spacing4: 4,
    spacing8: 8,
    spacing12: 12,
    spacing16: 16,
    spacing24: 24,
    spacing32: 32,
    radiusSmall: 4,
    radiusMedium: 12,
    radiusLarge: 16,
    radiusCircular: 9999,
    durationFast: const Duration(milliseconds: 150),
    durationNormal: const Duration(milliseconds: 250),
    durationSlow: const Duration(milliseconds: 400),
    artworkSizeMini: 40,
    artworkSizeCard: 56,
    artworkSizeFull: 280,
  );

  @override
  AppTokens copyWith({
    Color? colorPrimary,
    Color? colorOnPrimary,
    Color? colorSurface,
    Color? colorOnSurface,
    Color? colorSurfaceVariant,
    Color? colorOnSurfaceVariant,
    Color? colorOutline,
    Color? colorError,
    Color? colorMiniPlayer,
    Color? colorFocusRing,
    double? spacing4,
    double? spacing8,
    double? spacing12,
    double? spacing16,
    double? spacing24,
    double? spacing32,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? radiusCircular,
    Duration? durationFast,
    Duration? durationNormal,
    Duration? durationSlow,
    double? artworkSizeMini,
    double? artworkSizeCard,
    double? artworkSizeFull,
  }) => AppTokens(
    colorPrimary: colorPrimary ?? this.colorPrimary,
    colorOnPrimary: colorOnPrimary ?? this.colorOnPrimary,
    colorSurface: colorSurface ?? this.colorSurface,
    colorOnSurface: colorOnSurface ?? this.colorOnSurface,
    colorSurfaceVariant: colorSurfaceVariant ?? this.colorSurfaceVariant,
    colorOnSurfaceVariant:
        colorOnSurfaceVariant ?? this.colorOnSurfaceVariant,
    colorOutline: colorOutline ?? this.colorOutline,
    colorError: colorError ?? this.colorError,
    colorMiniPlayer: colorMiniPlayer ?? this.colorMiniPlayer,
    colorFocusRing: colorFocusRing ?? this.colorFocusRing,
    spacing4: spacing4 ?? this.spacing4,
    spacing8: spacing8 ?? this.spacing8,
    spacing12: spacing12 ?? this.spacing12,
    spacing16: spacing16 ?? this.spacing16,
    spacing24: spacing24 ?? this.spacing24,
    spacing32: spacing32 ?? this.spacing32,
    radiusSmall: radiusSmall ?? this.radiusSmall,
    radiusMedium: radiusMedium ?? this.radiusMedium,
    radiusLarge: radiusLarge ?? this.radiusLarge,
    radiusCircular: radiusCircular ?? this.radiusCircular,
    durationFast: durationFast ?? this.durationFast,
    durationNormal: durationNormal ?? this.durationNormal,
    durationSlow: durationSlow ?? this.durationSlow,
    artworkSizeMini: artworkSizeMini ?? this.artworkSizeMini,
    artworkSizeCard: artworkSizeCard ?? this.artworkSizeCard,
    artworkSizeFull: artworkSizeFull ?? this.artworkSizeFull,
  );

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      colorPrimary: Color.lerp(colorPrimary, other.colorPrimary, t)!,
      colorOnPrimary: Color.lerp(colorOnPrimary, other.colorOnPrimary, t)!,
      colorSurface: Color.lerp(colorSurface, other.colorSurface, t)!,
      colorOnSurface: Color.lerp(colorOnSurface, other.colorOnSurface, t)!,
      colorSurfaceVariant:
          Color.lerp(colorSurfaceVariant, other.colorSurfaceVariant, t)!,
      colorOnSurfaceVariant: Color.lerp(
        colorOnSurfaceVariant,
        other.colorOnSurfaceVariant,
        t,
      )!,
      colorOutline: Color.lerp(colorOutline, other.colorOutline, t)!,
      colorError: Color.lerp(colorError, other.colorError, t)!,
      colorMiniPlayer:
          Color.lerp(colorMiniPlayer, other.colorMiniPlayer, t)!,
      colorFocusRing: Color.lerp(colorFocusRing, other.colorFocusRing, t)!,
      spacing4: spacing4,
      spacing8: spacing8,
      spacing12: spacing12,
      spacing16: spacing16,
      spacing24: spacing24,
      spacing32: spacing32,
      radiusSmall: radiusSmall,
      radiusMedium: radiusMedium,
      radiusLarge: radiusLarge,
      radiusCircular: radiusCircular,
      durationFast: durationFast,
      durationNormal: durationNormal,
      durationSlow: durationSlow,
      artworkSizeMini: artworkSizeMini,
      artworkSizeCard: artworkSizeCard,
      artworkSizeFull: artworkSizeFull,
    );
  }
}

ThemeData buildLightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
  ),
  extensions: [AppTokens.light],
);

ThemeData buildDarkTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.dark,
  ),
  extensions: [AppTokens.dark],
);

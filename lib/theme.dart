import 'package:flutter/material.dart';
import 'package:mitril_play/models/settings.dart';

/// Cores base para cada paleta de tema
class ThemeColors {
  // Tema: Midnight Aurora (Aurora Boreal)
  static const auroraBackground = Color(0xFF0F172A);
  static const auroraCard = Color(0xFF1E293B);
  static const auroraSurface = Color(0xFF1E293B);
  static const auroraSurfaceHigh = Color(0xFF334155);
  static const auroraBorder = Color(0xFF334155);
  static const auroraPrimary = Color(0xFF818CF8);
  static const auroraPrimaryContainer = Color(0xFF6366F1);
  static const auroraSecondary = Color(0xFF34D399);
  static const auroraAccent = Color(0xFFF472B6);
  static const auroraText = Color(0xFFF1F5F9);
  static const auroraTextSecondary = Color(0xFFCBD5E1);

  // Tema: Cosmic Violet (Violeta Cósmico)
  static const cosmicBackground = Color(0xFF111022);
  static const cosmicCard = Color(0xFF1A1735);
  static const cosmicSurface = Color(0xFF1A1735);
  static const cosmicSurfaceHigh = Color(0xFF2A2550);
  static const cosmicBorder = Color(0xFF2D2A5E);
  static const cosmicPrimary = Color(0xFFA78BFA);
  static const cosmicPrimaryContainer = Color(0xFF7C3AED);
  static const cosmicSecondary = Color(0xFF38BDF8);
  static const cosmicAccent = Color(0xFFFBBF24);
  static const cosmicText = Color(0xFFF5F3FF);
  static const cosmicTextSecondary = Color(0xFFC4B5FD);

  // Tema: Ocean Depths (Profundezas Oceânicas)
  static const oceanBackground = Color(0xFF0C1222);
  static const oceanCard = Color(0xFF162032);
  static const oceanSurface = Color(0xFF162032);
  static const oceanSurfaceHigh = Color(0xFF1E293B);
  static const oceanBorder = Color(0xFF1E3A5F);
  static const oceanPrimary = Color(0xFF22D3EE);
  static const oceanPrimaryContainer = Color(0xFF06B6D4);
  static const oceanSecondary = Color(0xFF34D399);
  static const oceanAccent = Color(0xFFF59E0B);
  static const oceanText = Color(0xFFF0F9FF);
  static const oceanTextSecondary = Color(0xFF93C5FD);

  // Tema: Dark Premium (Original)
  static const darkBackground = Color(0xFF0F111A);
  static const darkCard = Color(0xFF1A1D29);
  static const darkSurface = Color(0xFF1A1D29);
  static const darkSurfaceHigh = Color(0xFF252937);
  static const darkBorder = Color(0xFF2D3245);
  static const darkPrimary = Color(0xFF6366F1);
  static const darkPrimaryContainer = Color(0xFF4F46E5);
  static const darkSecondary = Color(0xFF818CF8);
  static const darkAccent = Color(0xFFA78BFA);
  static const darkText = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
}

/// Alias de compatibilidade para código existente
/// Usa as cores do tema Dark Premium por padrão
class AppColors {
  static const background = ThemeColors.darkBackground;
  static const cardBackground = ThemeColors.darkCard;
  static const surfaceContainer = ThemeColors.darkSurface;
  static const surfaceContainerHighest = ThemeColors.darkSurfaceHigh;
  static const border = ThemeColors.darkBorder;
  static const textPrimary = ThemeColors.darkText;
  static const textSecondary = ThemeColors.darkTextSecondary;
  static const primary = ThemeColors.darkPrimary;
  static const primaryContainer = ThemeColors.darkPrimaryContainer;
  static const onPrimary = Colors.white;
  static const focusBorder = ThemeColors.darkPrimary;
  static const hoverBackground = Color(0xFF1E2235);
  static const snackbarBackground = Color(0xFF252937);
}

/// Tipografia com fonte Inter
class AppTypography {
  static const fontFamily = 'Inter';

  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );
}

/// Cria um tema baseado em um conjunto de cores
ThemeData _buildTheme({
  required Color background,
  required Color card,
  required Color surface,
  required Color surfaceHigh,
  required Color border,
  required Color primary,
  required Color primaryContainer,
  required Color secondary,
  required Color accent,
  required Color text,
  required Color textSecondary,
}) {
  final textTheme = AppTypography.textTheme.apply(
    displayColor: text,
    bodyColor: text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    fontFamily: AppTypography.fontFamily,
    colorScheme: ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainer: surface,
      surfaceContainerHighest: surfaceHigh,
      surfaceContainerLow: surface.withValues(alpha: 0.7),
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
    ),
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(color: text),
      displayMedium: textTheme.displayMedium?.copyWith(color: text),
      displaySmall: textTheme.displaySmall?.copyWith(color: text),
      headlineLarge: textTheme.headlineLarge?.copyWith(color: text),
      headlineMedium: textTheme.headlineMedium?.copyWith(color: text),
      headlineSmall: textTheme.headlineSmall?.copyWith(color: text),
      titleLarge: textTheme.titleLarge?.copyWith(color: text),
      titleMedium: textTheme.titleMedium?.copyWith(color: text),
      titleSmall: textTheme.titleSmall?.copyWith(color: text),
      bodyLarge: textTheme.bodyLarge?.copyWith(color: text),
      bodyMedium: textTheme.bodyMedium?.copyWith(color: text),
      bodySmall: textTheme.bodySmall?.copyWith(color: textSecondary),
      labelLarge: textTheme.labelLarge?.copyWith(color: text),
      labelMedium: textTheme.labelMedium?.copyWith(color: textSecondary),
      labelSmall: textTheme.labelSmall?.copyWith(color: textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: card,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black26,
      surfaceTintColor: card,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: text,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: text),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: BorderSide(color: border, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      hintStyle: TextStyle(color: textSecondary, fontFamily: AppTypography.fontFamily),
      labelStyle: TextStyle(color: textSecondary, fontFamily: AppTypography.fontFamily),
    ),
    listTileTheme: ListTileThemeData(
      textColor: text,
      iconColor: textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryContainer;
        }
        return surfaceHigh;
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: card,
      indicatorColor: primaryContainer,
      selectedIconTheme: IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: textSecondary),
      selectedLabelTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF252937),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    iconTheme: IconThemeData(
      color: textSecondary,
      size: 24,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: card,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: 1),
      ),
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      contentTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        color: textSecondary,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      surfaceTintColor: card,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: border, width: 1),
      ),
    ),
  );
}

/// Tema Light (claro completo)
ThemeData createLightTheme() {
  return _buildLightTheme(
    background: const Color(0xFFF8FAFC),
    card: Colors.white,
    surface: const Color(0xFFF1F5F9),
    surfaceHigh: const Color(0xFFE2E8F0),
    border: const Color(0xFFCBD5E1),
    primary: const Color(0xFF4F46E5),
    primaryContainer: const Color(0xFF6366F1),
    secondary: const Color(0xFF7C3AED),
    accent: const Color(0xFFA78BFA),
    text: const Color(0xFF0F172A),
    textSecondary: const Color(0xFF475569),
  );
}

/// Cria um tema claro completo
ThemeData _buildLightTheme({
  required Color background,
  required Color card,
  required Color surface,
  required Color surfaceHigh,
  required Color border,
  required Color primary,
  required Color primaryContainer,
  required Color secondary,
  required Color accent,
  required Color text,
  required Color textSecondary,
}) {
  final textTheme = AppTypography.textTheme.apply(
    displayColor: text,
    bodyColor: text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    fontFamily: AppTypography.fontFamily,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainer: surface,
      surfaceContainerHighest: surfaceHigh,
      surfaceContainerLow: background,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border,
      error: const Color(0xFFDC2626),
      onError: Colors.white,
    ),
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(color: text),
      displayMedium: textTheme.displayMedium?.copyWith(color: text),
      displaySmall: textTheme.displaySmall?.copyWith(color: text),
      headlineLarge: textTheme.headlineLarge?.copyWith(color: text),
      headlineMedium: textTheme.headlineMedium?.copyWith(color: text),
      headlineSmall: textTheme.headlineSmall?.copyWith(color: text),
      titleLarge: textTheme.titleLarge?.copyWith(color: text),
      titleMedium: textTheme.titleMedium?.copyWith(color: text),
      titleSmall: textTheme.titleSmall?.copyWith(color: text),
      bodyLarge: textTheme.bodyLarge?.copyWith(color: text),
      bodyMedium: textTheme.bodyMedium?.copyWith(color: text),
      bodySmall: textTheme.bodySmall?.copyWith(color: textSecondary),
      labelLarge: textTheme.labelLarge?.copyWith(color: text),
      labelMedium: textTheme.labelMedium?.copyWith(color: textSecondary),
      labelSmall: textTheme.labelSmall?.copyWith(color: textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: card,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      surfaceTintColor: card,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: text,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: text),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: BorderSide(color: border, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      hintStyle: TextStyle(color: textSecondary, fontFamily: AppTypography.fontFamily),
      labelStyle: TextStyle(color: textSecondary, fontFamily: AppTypography.fontFamily),
    ),
    listTileTheme: ListTileThemeData(
      textColor: text,
      iconColor: textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return const Color(0xFF94A3B8);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryContainer.withValues(alpha: 0.5);
        }
        return surfaceHigh;
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: card,
      indicatorColor: primaryContainer.withValues(alpha: 0.3),
      selectedIconTheme: IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: textSecondary),
      selectedLabelTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1E293B),
      contentTextStyle: TextStyle(color: Colors.white, fontFamily: AppTypography.fontFamily),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
    ),
    iconTheme: IconThemeData(
      color: textSecondary,
      size: 24,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: card,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: 1),
      ),
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      contentTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        color: textSecondary,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      surfaceTintColor: card,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: border, width: 1),
      ),
    ),
  );
}

/// Tema Dark Premium (original)
ThemeData createDarkTheme() {
  return _buildTheme(
    background: ThemeColors.darkBackground,
    card: ThemeColors.darkCard,
    surface: ThemeColors.darkSurface,
    surfaceHigh: ThemeColors.darkSurfaceHigh,
    border: ThemeColors.darkBorder,
    primary: ThemeColors.darkPrimary,
    primaryContainer: ThemeColors.darkPrimaryContainer,
    secondary: ThemeColors.darkSecondary,
    accent: ThemeColors.darkAccent,
    text: ThemeColors.darkText,
    textSecondary: ThemeColors.darkTextSecondary,
  );
}

/// Tema Black (AMOLED puro)
ThemeData createBlackTheme() {
  return _buildTheme(
    background: Colors.black,
    card: const Color(0xFF0A0A0A),
    surface: const Color(0xFF0A0A0A),
    surfaceHigh: const Color(0xFF1A1A1A),
    border: const Color(0xFF1A1A1A),
    primary: ThemeColors.darkPrimary,
    primaryContainer: ThemeColors.darkPrimaryContainer,
    secondary: ThemeColors.darkSecondary,
    accent: ThemeColors.darkAccent,
    text: ThemeColors.darkText,
    textSecondary: ThemeColors.darkTextSecondary,
  );
}

/// Tema Midnight Aurora (Aurora Boreal)
ThemeData createAuroraTheme() {
  return _buildTheme(
    background: ThemeColors.auroraBackground,
    card: ThemeColors.auroraCard,
    surface: ThemeColors.auroraSurface,
    surfaceHigh: ThemeColors.auroraSurfaceHigh,
    border: ThemeColors.auroraBorder,
    primary: ThemeColors.auroraPrimary,
    primaryContainer: ThemeColors.auroraPrimaryContainer,
    secondary: ThemeColors.auroraSecondary,
    accent: ThemeColors.auroraAccent,
    text: ThemeColors.auroraText,
    textSecondary: ThemeColors.auroraTextSecondary,
  );
}

/// Tema Cosmic Violet (Violeta Cósmico)
ThemeData createCosmicTheme() {
  return _buildTheme(
    background: ThemeColors.cosmicBackground,
    card: ThemeColors.cosmicCard,
    surface: ThemeColors.cosmicSurface,
    surfaceHigh: ThemeColors.cosmicSurfaceHigh,
    border: ThemeColors.cosmicBorder,
    primary: ThemeColors.cosmicPrimary,
    primaryContainer: ThemeColors.cosmicPrimaryContainer,
    secondary: ThemeColors.cosmicSecondary,
    accent: ThemeColors.cosmicAccent,
    text: ThemeColors.cosmicText,
    textSecondary: ThemeColors.cosmicTextSecondary,
  );
}

/// Tema Ocean Depths (Profundezas Oceânicas)
ThemeData createOceanTheme() {
  return _buildTheme(
    background: ThemeColors.oceanBackground,
    card: ThemeColors.oceanCard,
    surface: ThemeColors.oceanSurface,
    surfaceHigh: ThemeColors.oceanSurfaceHigh,
    border: ThemeColors.oceanBorder,
    primary: ThemeColors.oceanPrimary,
    primaryContainer: ThemeColors.oceanPrimaryContainer,
    secondary: ThemeColors.oceanSecondary,
    accent: ThemeColors.oceanAccent,
    text: ThemeColors.oceanText,
    textSecondary: ThemeColors.oceanTextSecondary,
  );
}

/// Fábrica de temas baseada no AppThemeMode
ThemeData getThemeByMode(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return createLightTheme();
    case AppThemeMode.dark:
      return createDarkTheme();
    case AppThemeMode.black:
      return createBlackTheme();
    case AppThemeMode.aurora:
      return createAuroraTheme();
    case AppThemeMode.cosmic:
      return createCosmicTheme();
    case AppThemeMode.ocean:
      return createOceanTheme();
  }
}

/// Converte AppThemeMode para string legível
String themeModeToString(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return 'Light';
    case AppThemeMode.dark:
      return 'Dark Premium';
    case AppThemeMode.black:
      return 'Black (AMOLED)';
    case AppThemeMode.aurora:
      return 'Midnight Aurora';
    case AppThemeMode.cosmic:
      return 'Cosmic Violet';
    case AppThemeMode.ocean:
      return 'Ocean Depths';
  }
}

/// Retorna o ícone do tema
IconData themeModeToIcon(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return Icons.wb_sunny_outlined;
    case AppThemeMode.dark:
      return Icons.brightness_2_outlined;
    case AppThemeMode.black:
      return Icons.brightness_1;
    case AppThemeMode.aurora:
      return Icons.nights_stay;
    case AppThemeMode.cosmic:
      return Icons.auto_awesome;
    case AppThemeMode.ocean:
      return Icons.waves;
  }
}

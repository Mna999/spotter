// core/theme/app_theme.dart
import 'package:flutter/material.dart';

const _spaceGrotesk = 'SpaceGrotesk';
const _plexSans = 'IBMPlexSans';
const _arabicFallback = ['Cairo'];

TextStyle _style(
  String family,
  double size,
  double height,
  FontWeight weight,
  double letterSpacingEm,
) {
  return TextStyle(
    fontFamily: family,
    fontFamilyFallback: _arabicFallback,
    fontSize: size,
    height: height / size,
    fontWeight: weight,
    letterSpacing: letterSpacingEm * size,
  );
}

final _textTheme = TextTheme(
  displayLarge: _style(
    _spaceGrotesk,
    56,
    60,
    FontWeight.w700,
    -0.04,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
  headlineLarge: _style(_spaceGrotesk, 32, 38, FontWeight.w700, -0.02),
  headlineMedium: _style(_spaceGrotesk, 24, 30, FontWeight.w600, -0.01),
  titleLarge: _style(_spaceGrotesk, 18, 24, FontWeight.w600, 0),
  bodyLarge: _style(_plexSans, 16, 24, FontWeight.w500, 0),
  bodyMedium: _style(_plexSans, 14, 20, FontWeight.w400, 0),
  bodySmall: _style(_plexSans, 12, 16, FontWeight.w400, 0.01),
  labelLarge: _style(_spaceGrotesk, 14, 18, FontWeight.w600, 0.04),
  labelMedium: _style(_spaceGrotesk, 12, 16, FontWeight.w600, 0.05),
  labelSmall: _style(_spaceGrotesk, 10, 14, FontWeight.w700, 0.08),
);

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.success, required this.warning});

  final Color success;
  final Color warning;

  @override
  AppColors copyWith({Color? success, Color? warning}) => AppColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

const _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF59EBAB),
  onPrimary: Color(0xFF0B1715),
  primaryContainer: Color(0xFF1A3830),
  onPrimaryContainer: Color(0xFF59EBAB),
  secondary: Color(0xFF56A986),
  onSecondary: Color(0xFF0B1715),
  secondaryContainer: Color(0xFF162F29),
  onSecondaryContainer: Color(0xFFD8E5E2),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF0B1715),
  onSurface: Color(0xFFFFFFFF),
  onSurfaceVariant: Color(0xFFC4C7C8),
  outline: Color(0xFF8E9192),
  outlineVariant: Color(0xFF1A3830),
  surfaceContainerLowest: Color(0xFF07100E),
  surfaceContainerLow: Color(0xFF112420),
  surfaceContainer: Color(0xFF162F29),
  surfaceContainerHigh: Color(0xFF201F1F),
  surfaceContainerHighest: Color(0xFF2A2A2A),
  inverseSurface: Color(0xFFD8E5E2),
  onInverseSurface: Color(0xFF273330),
  inversePrimary: Color(0xFF006C48),
);

const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006C48),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFBDF2D8),
  onPrimaryContainer: Color(0xFF005235),
  secondary: Color(0xFF2B7A63),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE4EFEA),
  onSecondaryContainer: Color(0xFF1B2B27),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF93000A),
  surface: Color(0xFFF2F8F5),
  onSurface: Color(0xFF0B1715),
  onSurfaceVariant: Color(0xFF3E4A45),
  outline: Color(0xFF5A6A64),
  outlineVariant: Color(0xFFCBDDD6),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFFFFFF),
  surfaceContainer: Color(0xFFE4EFEA),
  surfaceContainerHigh: Color(0xFFEDF3F0),
  surfaceContainerHighest: Color(0xFFE1E9E5),
  inverseSurface: Color(0xFF273330),
  onInverseSurface: Color(0xFFD8E5E2),
  inversePrimary: Color(0xFF59EBAB),
);

class AppTheme {
  const AppTheme._();

  static ThemeData get dark => _build(
    _darkScheme,
    const AppColors(success: Color(0xFF22C55E), warning: Color(0xFFF59E0B)),
  );

  static ThemeData get light => _build(
    _lightScheme,
    const AppColors(success: Color(0xFF15803D), warning: Color(0xFFB45309)),
  );
}

ThemeData _build(ColorScheme cs, AppColors extra) {
  final text = _textTheme.apply(
    bodyColor: cs.onSurface,
    displayColor: cs.onSurface,
  );
  final radius12 = BorderRadius.circular(12);
  final shape12 = RoundedRectangleBorder(borderRadius: radius12);

  OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
    borderRadius: radius12,
    borderSide: BorderSide(color: color),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    fontFamily: _plexSans,
    fontFamilyFallback: _arabicFallback,
    textTheme: text,
    extensions: [extra],
    appBarTheme: AppBarTheme(
      toolbarHeight: 64,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      shape: Border(bottom: BorderSide(color: cs.outlineVariant)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: cs.surface,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text.labelSmall!.copyWith(
          color: states.contains(WidgetState.selected)
              ? cs.primary
              : cs.onSurfaceVariant,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? cs.primary
              : cs.onSurfaceVariant,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        shape: shape12,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 56),
        shape: shape12,
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outlineVariant),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: cs.onSurface,
        textStyle: text.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: text.bodyMedium!.copyWith(color: cs.outline),
      prefixIconColor: cs.onSurfaceVariant,
      suffixIconColor: cs.onSurfaceVariant,
      border: inputBorder(cs.outlineVariant),
      focusedBorder: inputBorder(cs.primary),
      errorBorder: inputBorder(cs.error),
      focusedErrorBorder: inputBorder(cs.error),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius12,
        side: BorderSide(color: cs.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      backgroundColor: Colors.transparent,
      labelStyle: text.labelMedium!.copyWith(color: cs.onSurfaceVariant),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: cs.outlineVariant)),
        textStyle: WidgetStatePropertyAll(text.labelLarge),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.primary
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.onPrimary
              : cs.onSurfaceVariant,
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.selected)
              ? cs.primary
              : cs.outline,
        ),
      ),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? cs.primary
            : cs.surfaceContainer,
      ),
      checkColor: WidgetStatePropertyAll(cs.onPrimary),
    ),
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: cs.surfaceContainerLow,
      titleTextStyle: text.headlineMedium,
      shape: RoundedRectangleBorder(
        borderRadius: radius12,
        side: BorderSide(color: cs.outlineVariant),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: cs.primary,
      linearTrackColor: cs.surfaceContainer,
      circularTrackColor: cs.surfaceContainer,
      linearMinHeight: 6,
    ),
    dividerTheme: DividerThemeData(
      color: cs.outlineVariant,
      thickness: 1,
      space: 1,
    ),
  );
}

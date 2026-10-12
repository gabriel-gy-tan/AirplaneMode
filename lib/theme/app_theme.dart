import 'package:flutter/material.dart';

import 'shapes.dart';

enum AppThemeName { persona3, aero, phantom }

@immutable
class ThemeExtras extends ThemeExtension<ThemeExtras> {
  const ThemeExtras({required this.name});

  final AppThemeName name;

  @override
  ThemeExtras copyWith({AppThemeName? name}) => ThemeExtras(name: name ?? this.name);

  @override
  ThemeExtras lerp(ThemeExtension<ThemeExtras>? other, double t) {
    if (other is! ThemeExtras) return this;
    return t < 0.5 ? this : other;
  }
}

extension ThemeExtrasX on BuildContext {
  AppThemeName get themeName =>
      Theme.of(this).extension<ThemeExtras>()?.name ?? AppThemeName.persona3;
  bool get isAero => themeName == AppThemeName.aero;
  bool get isPhantom => themeName == AppThemeName.phantom;
}

/// Persona-inspired palette: midnight navy, steel blue, signal yellow.
class P3Palette {
  static const primary = Color(0xFF3E7BC7); // deep steel-blue accent
  static const steel = Color(0xFF183C67); // deep steel blue
  static const yellow = Color(0xFFF6D747); // signal yellow
  static const bg = Color(0xFF08172C); // midnight navy
  static const surface = Color(0xFF0C1E38);
  static const surfaceAlt = Color(0xFF122B4E);
  static const outline = Color(0xFF1F4A82);
  static const textPrimary = Color(0xFFF1F0E9); // warm white
  static const textSecondary = Color(0xFF8FA3C2); // muted blue-grey
}

/// Windows Vista-era Frutiger Aero palette: ice, sky, ocean, deep blue.
class AeroPalette {
  static const primary = Color(0xFF167CB5); // ocean blue
  static const deep = Color(0xFF12405F); // deep blue
  static const sky = Color(0xFF68C7EB); // sky blue
  static const green = Color(0xFF34C759);
  static const yellow = Color(0xFFFFCC00);
  static const skyTop = Color(0xFF68C7EB);
  static const skyBottom = Color(0xFFD9F5FF); // ice blue
  static const textPrimary = Color(0xFF12405F); // deep blue
  static const textSecondary = Color(0xFF3E6B8F);
  static const glass = Color(0xCCFFFFFF);
  static const outline = Color(0xFF9BDCF2);

  /// Classic Aero panel: vertical blue gradient, bright top-edge
  /// highlight, defined outline and a soft visible drop shadow.
  static BoxDecoration panelDecoration({BorderRadius? radius}) => BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(14),
        border: Border.all(color: outline),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12405F).withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE6FFFFFF), Color(0xCCFFFFFF), Color(0xB3F2FBFF)],
          stops: [0, 0.18, 1],
        ),
      );

  /// Glossy raised control (buttons, toggles).
  static BoxDecoration glossButtonDecoration({
    required Color base,
    BorderRadius? radius,
  }) =>
      BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(base, Colors.white, 0.45)!,
            base,
            Color.lerp(base, Colors.black, 0.18)!,
          ],
          stops: const [0, 0.45, 1],
        ),
      );
}

/// Phantom palette: near-black navy plates, electric blue blocks,
/// signal-yellow cursors and off-white display type.
class PhantomPalette {
  static const bg = Color(0xFF080B18); // near-black navy
  static const surface = Color(0xFF111A35); // deep midnight blue
  static const blue = Color(0xFF2457D6); // electric blue
  static const yellow = Color(0xFFF7E600); // signal yellow
  static const text = Color(0xFFF4F1E8); // off-white
  static const muted = Color(0xFF8992A9); // muted grey-blue
  static const ink = Color(0xFF04060F); // hard-shadow ink
  static const hairline = Color(0x38F4F1E8); // thin off-white outline
}

/// Square slider thumb with a hard offset block (Phantom).
class PhantomSquareThumb extends SliderComponentShape {
  const PhantomSquareThumb({this.size = 15});

  final double size;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.square(size);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(center: center, width: size, height: size);
    canvas.drawRect(
      rect.translate(2.5, 2.5),
      Paint()..color = PhantomPalette.ink,
    );
    canvas.drawRect(
      rect,
      Paint()..color = sliderTheme.thumbColor ?? PhantomPalette.yellow,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = PhantomPalette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}

abstract class AppTheme {
  static ThemeData persona3() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Rajdhani',
      scaffoldBackgroundColor: P3Palette.bg,
      colorScheme: const ColorScheme.dark(
        primary: P3Palette.yellow,
        secondary: P3Palette.yellow,
        surface: P3Palette.surface,
        onSurface: P3Palette.textPrimary,
        outline: P3Palette.outline,
      ),
    );
    return base.copyWith(
      extensions: const [ThemeExtras(name: AppThemeName.persona3)],
      textTheme: _p3TextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: 3,
          color: P3Palette.textPrimary,
        ),
        iconTheme: IconThemeData(color: P3Palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: P3Palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: CutCornerBorder(
          radius: 6,
          side: const BorderSide(color: P3Palette.outline, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: P3Palette.yellow,
          foregroundColor: P3Palette.bg,
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          shape: const CutCornerBorder(radius: 5),
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: P3Palette.textPrimary,
          minimumSize: const Size(44, 44),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: P3Palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          side: BorderSide(color: P3Palette.outline),
        ),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 4,
        activeTrackColor: P3Palette.yellow,
        inactiveTrackColor: P3Palette.steel,
        thumbColor: P3Palette.yellow,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
        showValueIndicator: ShowValueIndicator.never,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? P3Palette.yellow
                : P3Palette.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? P3Palette.yellow.withValues(alpha: 0.35)
                : P3Palette.surfaceAlt),
      ),
      dividerTheme: const DividerThemeData(color: P3Palette.outline, thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: P3Palette.yellow,
        textColor: P3Palette.textPrimary,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: P3Palette.yellow),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: P3Palette.surfaceAlt,
        contentTextStyle: const TextStyle(
            fontFamily: 'Rajdhani', color: P3Palette.textPrimary, fontSize: 15),
        behavior: SnackBarBehavior.floating,
        shape: const CutCornerBorder(
            radius: 6, side: BorderSide(color: P3Palette.outline)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? P3Palette.yellow
                : P3Palette.textSecondary),
      ),
    );
  }

  static ThemeData aero() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: AeroPalette.skyBottom,
      colorScheme: const ColorScheme.light(
        primary: AeroPalette.primary,
        secondary: AeroPalette.green,
        surface: Colors.white,
        onSurface: AeroPalette.textPrimary,
        outline: AeroPalette.outline,
      ),
    );
    return base.copyWith(
      extensions: const [ThemeExtras(name: AppThemeName.aero)],
      textTheme: _aeroTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _aeroStyle(
          fontWeight: FontWeight.w800,
          fontSize: 24,
          color: AeroPalette.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AeroPalette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        margin: EdgeInsets.zero,
        shadowColor: AeroPalette.deep.withValues(alpha: 0.35),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AeroPalette.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AeroPalette.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: _aeroStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AeroPalette.textPrimary,
          minimumSize: const Size(44, 44),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.97),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 6,
        activeTrackColor: AeroPalette.primary,
        inactiveTrackColor: Color(0xFFBFE6F5),
        thumbColor: Colors.white,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
        showValueIndicator: ShowValueIndicator.never,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AeroPalette.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AeroPalette.primary
                : const Color(0xFFC9DEEC)),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AeroPalette.deep.withValues(alpha: 0.4)
                : AeroPalette.outline),
      ),
      dividerTheme:
          DividerThemeData(color: AeroPalette.outline, thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: AeroPalette.primary,
        textColor: AeroPalette.textPrimary,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AeroPalette.primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: _aeroStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AeroPalette.textPrimary),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AeroPalette.primary
                : AeroPalette.textSecondary),
      ),
    );
  }

  static ThemeData phantom() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Rajdhani',
      scaffoldBackgroundColor: PhantomPalette.bg,
      colorScheme: const ColorScheme.dark(
        primary: PhantomPalette.yellow,
        secondary: PhantomPalette.blue,
        surface: PhantomPalette.surface,
        onSurface: PhantomPalette.text,
        outline: PhantomPalette.muted,
      ),
    );
    return base.copyWith(
      extensions: const [ThemeExtras(name: AppThemeName.phantom)],
      textTheme: _phantomTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: 4,
          color: PhantomPalette.text,
        ),
        iconTheme: IconThemeData(color: PhantomPalette.text),
      ),
      cardTheme: CardThemeData(
        color: PhantomPalette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: CutCornerBorder(
          radius: 10,
          diagonal: true,
          side: const BorderSide(color: PhantomPalette.hairline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PhantomPalette.yellow,
          foregroundColor: PhantomPalette.bg,
          elevation: 0,
          shadowColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          shape: const SlantBorder(slant: 11),
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 2.4,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PhantomPalette.yellow,
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 2.4,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: PhantomPalette.text,
          minimumSize: const Size(44, 44),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PhantomPalette.surface,
        surfaceTintColor: Colors.transparent,
        shape: CutCornerBorder(
          radius: 12,
          diagonal: true,
          side: BorderSide(color: PhantomPalette.hairline),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: PhantomPalette.yellow,
        inactiveTrackColor: PhantomPalette.surface,
        thumbColor: PhantomPalette.yellow,
        thumbShape: const PhantomSquareThumb(),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        overlayColor: PhantomPalette.yellow.withValues(alpha: 0.16),
        showValueIndicator: ShowValueIndicator.never,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? PhantomPalette.bg
                : PhantomPalette.muted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? PhantomPalette.yellow
                : PhantomPalette.surface),
        trackOutlineColor: WidgetStatePropertyAll(PhantomPalette.hairline),
      ),
      dividerTheme: const DividerThemeData(
        color: PhantomPalette.hairline,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: PhantomPalette.yellow,
        textColor: PhantomPalette.text,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: PhantomPalette.yellow),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PhantomPalette.ink,
        contentTextStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            color: PhantomPalette.text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1),
        behavior: SnackBarBehavior.floating,
        shape: const CutCornerBorder(
            radius: 8,
            diagonal: true,
            side: BorderSide(color: PhantomPalette.yellow)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? PhantomPalette.yellow
                : PhantomPalette.muted),
      ),
    );
  }

  static TextTheme _p3TextTheme(TextTheme base) {
    TextStyle style(double size, FontWeight weight,
            {Color color = P3Palette.textPrimary, double spacing = 1.2}) =>
        TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color,
          height: 1.15,
        );
    return base.copyWith(
      displayLarge: style(44, FontWeight.w700, spacing: 4),
      displayMedium: style(32, FontWeight.w700, spacing: 3),
      headlineLarge: style(26, FontWeight.w700, spacing: 2),
      headlineMedium: style(22, FontWeight.w600, spacing: 1.8),
      titleLarge: style(19, FontWeight.w700, spacing: 2.4),
      titleMedium: style(16, FontWeight.w600, spacing: 1.2),
      bodyLarge: style(16, FontWeight.w500, color: P3Palette.textPrimary),
      bodyMedium: style(14, FontWeight.w500, color: P3Palette.textSecondary),
      bodySmall: style(12, FontWeight.w500, color: P3Palette.textSecondary),
      labelLarge: style(14, FontWeight.w700, spacing: 2.2),
      labelMedium: style(12, FontWeight.w600, spacing: 1.6),
      labelSmall: style(11, FontWeight.w600, spacing: 1.6,
          color: P3Palette.textSecondary),
    );
  }

  static TextStyle _aeroStyle({
    FontWeight fontWeight = FontWeight.w600,
    double fontSize = 15,
    Color color = AeroPalette.textPrimary,
    double height = 1.25,
  }) {
    return TextStyle(
      fontFamily: 'Nunito',
      fontVariations: [FontVariation('wght', fontWeightToWght(fontWeight))],
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      height: height,
    );
  }

  static double fontWeightToWght(FontWeight w) => w.value.toDouble();

  static TextTheme _aeroTextTheme(TextTheme base) {
    TextStyle style(double size, FontWeight weight,
        {Color color = AeroPalette.textPrimary}) {
      return TextStyle(
        fontFamily: 'Nunito',
        fontVariations: [FontVariation('wght', fontWeightToWght(weight))],
        fontWeight: weight,
        fontSize: size,
        color: color,
        height: 1.3,
      );
    }

    return base.copyWith(
      displayLarge: style(40, FontWeight.w900),
      displayMedium: style(30, FontWeight.w900),
      headlineLarge: style(26, FontWeight.w800),
      headlineMedium: style(22, FontWeight.w800),
      titleLarge: style(19, FontWeight.w800),
      titleMedium: style(16, FontWeight.w700),
      bodyLarge: style(16, FontWeight.w600),
      bodyMedium:
          style(14, FontWeight.w600, color: AeroPalette.textSecondary),
      bodySmall: style(12, FontWeight.w600, color: AeroPalette.textSecondary),
      labelLarge: style(14, FontWeight.w800),
      labelMedium: style(13, FontWeight.w700),
      labelSmall: style(11, FontWeight.w700, color: AeroPalette.textSecondary),
    );
  }

  /// Phantom: huge condensed Rajdhani display headings mixed with tiny
  /// uppercase technical labels, and Nunito for readable long-form text.
  static TextTheme _phantomTextTheme(TextTheme base) {
    TextStyle display(double size,
            {double spacing = 3, Color color = PhantomPalette.text}) =>
        TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: size,
          fontWeight: FontWeight.w700,
          letterSpacing: spacing,
          color: color,
          height: 1.04,
        );
    TextStyle tech(double size,
            {Color color = PhantomPalette.muted, double spacing = 2.4}) =>
        TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: size,
          fontWeight: FontWeight.w700,
          letterSpacing: spacing,
          color: color,
          height: 1.2,
        );
    TextStyle readable(double size,
            {FontWeight weight = FontWeight.w700,
            Color color = PhantomPalette.text}) =>
        TextStyle(
          fontFamily: 'Nunito',
          fontVariations: [FontVariation('wght', weight.value.toDouble())],
          fontWeight: weight,
          fontSize: size,
          color: color,
          height: 1.3,
        );

    return base.copyWith(
      displayLarge: display(50, spacing: 6),
      displayMedium: display(34, spacing: 4),
      headlineLarge: display(28, spacing: 2.5),
      headlineMedium: display(23, spacing: 2),
      titleLarge: display(20, spacing: 2),
      titleMedium: readable(15.5),
      titleSmall: readable(14, weight: FontWeight.w700),
      bodyLarge: readable(15),
      bodyMedium: readable(13.5, color: PhantomPalette.muted),
      bodySmall: readable(12, color: PhantomPalette.muted),
      labelLarge: tech(15),
      labelMedium: tech(13),
      labelSmall: tech(11.5, spacing: 1.8),
    );
  }
}

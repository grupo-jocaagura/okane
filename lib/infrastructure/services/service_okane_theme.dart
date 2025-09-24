import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Servicio de temas de Okane.
///
/// # Ejemplo de uso (MD)
/// ```dart
/// // Inyecta el servicio en el Gateway para saneo + smoke-test:
/// final GatewayThemeImpl gateway = GatewayThemeImpl(
///   themeService: const ServiceOkaneTheme(),
/// );
/// // Construye tu Repository/Usecases/Bloc como acostumbras…
/// // Luego, al pedir el ThemeData, pasa Roboto (ver apartado 2).
/// ```
///
/// Mantiene M3, respeta overrides por esquema, y escala tipografía.
class ServiceOkaneTheme extends ServiceTheme {
  const ServiceOkaneTheme();

  @override
  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  }) {
    final Brightness b = switch (state.mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      _ => platformBrightness,
    };
    return _build(state, b);
  }

  @override
  ThemeData lightTheme(ThemeState state) => _build(state, Brightness.light);

  @override
  ThemeData darkTheme(ThemeState state) => _build(state, Brightness.dark);

  @override
  ColorScheme schemeFromSeed(Color seed, Brightness brightness) {
    final ColorScheme s = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    assert(s.brightness == brightness);
    return s;
  }

  ThemeData _build(ThemeState state, Brightness brightness) {
    // 1) ColorScheme base desde seed
    ColorScheme scheme = schemeFromSeed(state.seed, brightness);

    // 2) Si hay overrides por esquema, respétalos
    final ThemeOverrides? ov = state.overrides;
    if (ov != null) {
      final ColorScheme? forced = brightness == Brightness.dark
          ? ov.dark
          : ov.light;
      if (forced != null && forced.brightness == brightness) {
        scheme = forced;
      }
    }

    // 3) Roboto + escala y colores del esquema
    final TextTheme baseRoboto = GoogleFonts.robotoTextTheme()
        .apply(displayColor: scheme.onSurface, bodyColor: scheme.onSurface)
        .apply(fontSizeFactor: state.textScale);

    // 4) ThemeData final (M3 según state)
    return ThemeData(
      useMaterial3: state.useMaterial3,
      colorScheme: scheme,
      brightness: scheme.brightness,
      textTheme: baseRoboto,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
    );
  }
}

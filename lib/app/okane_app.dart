import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// OkaneApp: shell de aplicación que inyecta tipografía y esquemas de color.
///
/// ### ¿Qué hace distinto?
/// 1) Inyecta Roboto (o un `TextTheme` propio) en `MaterialApp`
/// 2) Permite forzar `ColorScheme` light/dark (si no se pasan, respeta el flujo por seed/overrides)
///
/// ### Ejemplo (MD)
/// ```dart
/// runApp(
///   OkaneApp(
///     appManager: appManager,
///     registry: pageRegistry,
///     // Opcional: forzar esquemas si aún no los persistes como overrides:
///     lightScheme: lightColorScheme, // tus esquemas del mensaje anterior
///     darkScheme: darkColorScheme,
///     // Opcional: usar tipografía propia (por defecto usa Roboto)
///     baseTextThemeBuilder: (ColorScheme scheme, double textScale) {
///       return GoogleFonts.robotoTextTheme()
///         .apply(displayColor: scheme.onSurface, bodyColor: scheme.onSurface)
///         .apply(fontSizeFactor: textScale);
///     },
///   ),
/// );
/// ```
class OkaneApp extends StatelessWidget {
  const OkaneApp({
    required this.appManager,
    required this.registry,
    this.ownsManager = false,
    this.projectorMode = false,
    this.initialLocation = '/home',
    this.lightScheme,
    this.darkScheme,
    this.baseTextThemeBuilder,
    super.key,
  });

  /// Factory de desarrollo (equivalente a `JocaaguraApp.dev`) con inyección Okane.
  factory OkaneApp.dev({
    required PageRegistry registry,
    required bool projectorMode,
    Key? key,
    String initialLocation = '/home',
    List<OnboardingStep> onboardingSteps = const <OnboardingStep>[],
    ColorScheme? lightScheme,
    ColorScheme? darkScheme,
    TextTheme Function(ColorScheme scheme, double textScale)?
    baseTextThemeBuilder,
  }) {
    final AppConfig config = AppConfig.dev(
      registry: registry,
      onboardingSteps: onboardingSteps,
    );
    final AppManager manager = AppManager(config);
    return OkaneApp(
      key: key,
      appManager: manager,
      registry: registry,
      initialLocation: initialLocation,
      ownsManager: true,
      lightScheme: lightScheme,
      darkScheme: darkScheme,
      baseTextThemeBuilder: baseTextThemeBuilder,
    );
  }

  /// Domain app manager (theme, navigation, loading, etc.)
  final AppManager appManager;

  /// Page registry
  final PageRegistry registry;

  /// Projector mode
  final bool projectorMode;

  /// Initial route
  final String initialLocation;

  /// Whether this widget disposes [appManager].
  final bool ownsManager;

  /// Esquemas opcionales para forzar Light/Dark (si null, usa los del estado).
  final ColorScheme? lightScheme;
  final ColorScheme? darkScheme;

  /// Builder opcional para la tipografía base (por defecto: Roboto + onSurface + escala).
  final TextTheme Function(ColorScheme scheme, double textScale)?
  baseTextThemeBuilder;

  @override
  Widget build(BuildContext context) {
    return AppManagerProvider(
      appManager: appManager,
      child: _OkaneAppShell(
        appManager: appManager,
        registry: registry,
        initialLocation: initialLocation,
        ownsManager: ownsManager,
        lightScheme: lightScheme,
        darkScheme: darkScheme,
        baseTextThemeBuilder: baseTextThemeBuilder,
      ),
    );
  }
}

class _OkaneAppShell extends StatefulWidget {
  const _OkaneAppShell({
    required this.appManager,
    required this.registry,
    required this.initialLocation,
    required this.ownsManager,
    required this.lightScheme,
    required this.darkScheme,
    required this.baseTextThemeBuilder,
  });

  final AppManager appManager;
  final PageRegistry registry;
  final String initialLocation;
  final bool ownsManager;

  final ColorScheme? lightScheme;
  final ColorScheme? darkScheme;
  final TextTheme Function(ColorScheme scheme, double textScale)?
  baseTextThemeBuilder;

  @override
  State<_OkaneAppShell> createState() => _OkaneAppShellState();
}

class _OkaneAppShellState extends State<_OkaneAppShell>
    with WidgetsBindingObserver {
  late final MyRouteInformationParser _parser;
  late final MyAppRouterDelegate _delegate;
  late final PlatformRouteInformationProvider _routeInfoProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _parser = const MyRouteInformationParser();
    _delegate = MyAppRouterDelegate(
      registry: widget.registry,
      pageManager: widget.appManager.pageManager,
    );
    _routeInfoProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(
        uri: Uri.parse(widget.initialLocation),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.appManager.handleLifecycle(state);
    if (state == AppLifecycleState.detached) {
      if (widget.ownsManager && !widget.appManager.isDisposed) {
        widget.appManager.dispose();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _routeInfoProvider.dispose();
    } catch (_) {}
    try {
      _delegate.dispose();
    } catch (_) {}
    super.dispose();
  }

  TextTheme _resolveBaseTextTheme(ColorScheme scheme, double textScale) {
    final TextTheme Function(ColorScheme, double)? b =
        widget.baseTextThemeBuilder;
    if (b != null) {
      return b(scheme, textScale);
    }
    // Default: Roboto + colores del esquema + escala.
    return GoogleFonts.robotoTextTheme()
        .apply(displayColor: scheme.onSurface, bodyColor: scheme.onSurface)
        .apply(fontSizeFactor: textScale);
  }

  @override
  Widget build(BuildContext context) {
    final AppManager am = widget.appManager;

    _delegate.update(pageManager: am.pageManager, registry: widget.registry);

    return StreamBuilder<ThemeState>(
      stream: am.theme.stream,
      initialData: am.theme.stateOrDefault,
      builder: (__, AsyncSnapshot<ThemeState> snap) {
        final ThemeState raw = snap.data ?? ThemeState.defaults;

        // Si el estado aún no tiene overrides y nos pasaron esquemas, úsalos como fallback.
        ThemeState s = raw;
        if (s.overrides == null &&
            (widget.lightScheme != null || widget.darkScheme != null)) {
          s = s.copyWith(
            overrides: ThemeOverrides(
              light: widget.lightScheme,
              dark: widget.darkScheme,
            ),
          );
        }

        // Resuelve el scheme efectivo para light/dark *tal como lo haría BuildThemeData*,
        // solo para poder crear el TextTheme coloreado correctamente.
        ColorScheme schemeFor(ThemeMode mode) {
          final bool isDark = mode == ThemeMode.dark;
          final ColorScheme base = ColorScheme.fromSeed(
            seedColor: s.seed,
            brightness: isDark ? Brightness.dark : Brightness.light,
          );
          final ColorScheme? ovr = isDark
              ? s.overrides?.dark
              : s.overrides?.light;
          if (ovr == null) {
            return base;
          }
          // copiamos los campos relevantes como hace tu _mergeOverrides
          return base.copyWith(
            primary: ovr.primary,
            onPrimary: ovr.onPrimary,
            secondary: ovr.secondary,
            onSecondary: ovr.onSecondary,
            tertiary: ovr.tertiary,
            onTertiary: ovr.onTertiary,
            error: ovr.error,
            onError: ovr.onError,
            surface: ovr.surface,
            onSurface: ovr.onSurface,
            surfaceTint: ovr.surfaceTint,
            outline: ovr.outline,
            onSurfaceVariant: ovr.onSurfaceVariant,
            inverseSurface: ovr.inverseSurface,
            inversePrimary: ovr.inversePrimary,
          );
        }

        final ColorScheme lightScheme = schemeFor(ThemeMode.light);
        final ColorScheme darkScheme = schemeFor(ThemeMode.dark);

        final TextTheme lightBase = _resolveBaseTextTheme(
          lightScheme,
          s.textScale,
        );
        final TextTheme darkBase = _resolveBaseTextTheme(
          darkScheme,
          s.textScale,
        );

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerDelegate: _delegate,
          routeInformationParser: _parser,
          routeInformationProvider: _routeInfoProvider,
          restorationScopeId: 'app',
          // ¡Clave!: pasar baseTextTheme ya resuelto (Roboto por defecto).
          theme: const BuildThemeData().fromState(
            s.copyWith(mode: ThemeMode.light),
            baseTextTheme: lightBase,
          ),
          darkTheme: const BuildThemeData().fromState(
            s.copyWith(mode: ThemeMode.dark),
            baseTextTheme: darkBase,
          ),
          themeMode: s.mode,
        );
      },
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'app/okane_app.dart';
import 'config.dart';
import 'ui/theme/global_theme.dart';
import 'ui/views/splash_screen_view.dart';
import 'ui/views/views.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google-fonts'], license);
  });

  runApp(
    OkaneApp(
      appManager: appManager,
      registry: pageRegistry,
      initialLocation: SplashScreenView.pageModel.toUriString(),
      lightScheme: lightColorScheme,
      darkScheme: darkColorScheme,
      baseTextThemeBuilder: (ColorScheme scheme, double textScale) {
        return GoogleFonts.robotoTextTheme()
            .apply(displayColor: scheme.onSurface, bodyColor: scheme.onSurface)
            .apply(fontSizeFactor: textScale);
      },
    ),
  );
}

extension PageManagerDebugX on PageManager {
  void debugLogStack([String tag = '']) {
    final String chain = stack.pages.map((PageModel p) => p.name).join(' > ');
    debugPrint('[STACK$tag] $chain');
  }
}

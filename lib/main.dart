import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'config.dart';
import 'ui/views/splash_screen_view.dart';
import 'ui/views/views.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google-fonts'], license);
  });

  // appManager.theme.customThemeFromColorScheme(
  //   isDarkMode ? darkColorScheme : lightColorScheme,
  //   GoogleFonts.robotoTextTheme(),
  //   isDarkMode,
  // );

  runApp(
    JocaaguraApp(
      appManager: appManager,
      registry: pageRegistry,
      initialLocation: SplashScreenView.pageModel.toUriString(),
    ),
  );
}

extension PageManagerDebugX on PageManager {
  void debugLogStack([String tag = '']) {
    final String chain = stack.pages.map((PageModel p) => p.name).join(' > ');
    debugPrint('[STACK$tag] $chain');
  }
}

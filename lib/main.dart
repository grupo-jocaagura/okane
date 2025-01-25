import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jocaaguraarchetype/ui/jocaagura_app.dart';

import 'config.dart';
import 'ui/theme/global_theme.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google-fonts'], license);
  });
  WidgetsFlutterBinding.ensureInitialized();
  final Brightness brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  final bool isDarkMode = brightness == Brightness.dark;
  appManager.theme.customThemeFromColorScheme(
    isDarkMode ? darkColorScheme : lightColorScheme,
    GoogleFonts.robotoTextTheme(),
    isDarkMode,
  );
  runApp(
    JocaaguraApp(appManager: appManager),
  );
}

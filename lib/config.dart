import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'app/env.dart';
import 'app/okane_environment.dart';

/// Global composition root used by the current Okane application.
///
/// The environment is selected explicitly from the launch command with:
/// `--dart-define=OKANE_ENV=<dev|qa|prod>`.
final AppManager appManager = AppManager(
 OkaneEnv.build(resolveOkaneEnvironmentFromDefines()),
);

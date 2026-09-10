import 'env.dart';

/// Compile-time key used to select the Okane runtime environment.
const String kOkaneEnvironmentDefine = 'OKANE_ENV';

/// Resolves an [AppEnvironment] from the value supplied through
/// `--dart-define=OKANE_ENV=<dev|qa|prod>`.
AppEnvironment resolveOkaneEnvironment(String rawValue) {
  switch (rawValue.trim().toLowerCase()) {
    case 'dev':
      return AppEnvironment.dev;
    case 'qa':
      return AppEnvironment.qa;
    case 'prod':
      return AppEnvironment.prod;
    default:
      throw StateError(
        '$kOkaneEnvironmentDefine is required and must be one of: '
        'dev, qa, prod. '
        'Launch Okane with '
        '--dart-define=$kOkaneEnvironmentDefine=<dev|qa|prod>.',
      );
  }
}

/// Resolves the environment selected at compile time.
AppEnvironment resolveOkaneEnvironmentFromDefines() {
  return resolveOkaneEnvironment(
    const String.fromEnvironment(kOkaneEnvironmentDefine),
  );
}

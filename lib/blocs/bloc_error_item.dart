import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// BLoC destinado a manejar errores presentados por cualquier otro módulo.
///
/// Este BLoC permite centralizar el reporte, observación y limpieza de errores en tiempo real.
class BlocError extends BlocModule {
  static const String name = 'blocError';

  final BlocGeneral<ErrorItem?> lastError = BlocGeneral<ErrorItem?>(null);

  /// Reporta un nuevo error al estado reactivo.
  void report(ErrorItem error) {
    clear();
    lastError.value = error;
  }

  /// Limpia el error actual, útil después de mostrarlo en la UI.
  void clear() {
    lastError.value = null;
  }

  /// Libera recursos del BLoC.
  @override
  void dispose() {
    lastError.dispose();
  }

  /// Para debugging.
  @override
  String toString() {
    final ErrorItem? current = lastError.value;
    return current == null
        ? 'Sin errores'
        : '🛑 ${current.title} (${current.code}) → ${current.description}';
  }
}

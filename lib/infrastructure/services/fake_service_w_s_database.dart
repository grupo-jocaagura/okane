import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../domain/entities/services/service_w_s_database.dart';

/// Servicio WS simulado para pruebas en Okane.
///
/// Soporta un único ledger por nombre bajo el path `okane/{ledger.nameOfLedger}`.
class FakeServiceWSDatabase implements ServiceWSDatabase {
  static const String _okanePrefix = 'okane/';
  static ErrorItem notFound(String path) => ErrorItem(
        title: 'Dato no encontrado',
        description: 'No existe ledger en $path',
        code: 'NOT_FOUND',
      );

  final BlocGeneral<Either<ErrorItem, Map<String, dynamic>>> _ledgerStream =
      BlocGeneral<Either<ErrorItem, Map<String, dynamic>>>(
    Left<ErrorItem, Map<String, dynamic>>(
      notFound('okane/default'),
    ),
  );

  Map<String, dynamic>? _ledgerJson;

  @override
  Future<Either<ErrorItem, void>> write(
    String path,
    Map<String, dynamic> data,
  ) async {
    if (!path.startsWith(_okanePrefix)) {
      _ledgerStream.value = Left<ErrorItem, Map<String, dynamic>>(
        notFound(path),
      );
      return _ledgerStream.value;
    }

    _ledgerJson = data;
    _ledgerStream.value = Right<ErrorItem, Map<String, dynamic>>(data);
    return _ledgerStream.value;
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String path) async {
    if (path.startsWith(_okanePrefix) && _ledgerJson != null) {
      return Right<ErrorItem, Map<String, dynamic>>(_ledgerJson!);
    }
    return Left<ErrorItem, Map<String, dynamic>>(notFound(path));
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> onValue(String path) {
    return _ledgerStream.stream;
  }

  /// Limpia el estado simulado y reinicia el stream con error.
  void reset() {
    _ledgerJson = null;
    _ledgerStream.value =
        Left<ErrorItem, Map<String, dynamic>>(notFound('okane/default'));
  }

  void dispose() {
    _ledgerStream.dispose();
  }
}

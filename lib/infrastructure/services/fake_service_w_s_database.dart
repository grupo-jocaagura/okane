import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../../domain/entities/services/service_w_s_database.dart';
import '../../domain/gateway/ledger_ws_gateway.dart';

/// Servicio WS simulado para pruebas en Okane.
///
/// Soporta un único ledger por nombre bajo el path `okane/{ledger.nameOfLedger}`.
class FakeServiceWSDatabase implements ServiceWSDatabase {
  static ErrorItem notFound(String path) => ErrorItem(
    title: 'Dato no encontrado',
    description: 'No existe ledger en $path',
    code: 'NOT_FOUND',
  );

  final BlocGeneral<Either<ErrorItem, Map<String, dynamic>>> _ledgerStream =
      BlocGeneral<Either<ErrorItem, Map<String, dynamic>>>(
        Left<ErrorItem, Map<String, dynamic>>(notFound('okane/default')),
      );

  Map<String, dynamic> _ledgerJson = defaultOkaneLedger.toJson();

  @override
  Future<Either<ErrorItem, void>> write(
    String path,
    Map<String, dynamic> data,
  ) async {
    if (!path.startsWith(LedgerWsGateway.ledgerPath)) {
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
    if (path.startsWith(LedgerWsGateway.ledgerPath)) {
      return Right<ErrorItem, Map<String, dynamic>>(_ledgerJson);
    }
    return Left<ErrorItem, Map<String, dynamic>>(notFound(path));
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> onValue(String path) {
    return _ledgerStream.stream;
  }

  /// Limpia el estado simulado y reinicia el stream con error.
  void reset() {
    _ledgerJson = defaultOkaneLedger.toJson();
    _ledgerStream.value = Left<ErrorItem, Map<String, dynamic>>(
      notFound('okane/default'),
    );
  }

  void dispose() {
    _ledgerStream.dispose();
  }
}

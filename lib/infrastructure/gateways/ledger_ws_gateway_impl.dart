import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../domain/entities/services/service_w_s_database.dart';
import '../../domain/gateway/ledger_ws_gateway.dart';

/// Implementación del Gateway WebSocket que interactúa con la fuente de datos externa.
///
/// Se limita a operaciones con Map<String, dynamic>. No realiza parsing a modelos.
class LedgerWsGatewayImpl implements LedgerWsGateway {
  LedgerWsGatewayImpl(this._service);
  final ServiceWSDatabase _service;

  @override
  Future<Either<ErrorItem, void>> saveLedger(Map<String, dynamic> ledger) {
    final String path =
        '${LedgerWsGateway.ledgerPath}/${ledger['nameOfLedger'] ?? "okane"}';
    return _service.write(path, ledger);
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> fetchLedger() {
    return _service.read(LedgerWsGateway.ledgerPath);
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> onLedgerUpdated() {
    return _service.onValue(LedgerWsGateway.ledgerPath);
  }
}

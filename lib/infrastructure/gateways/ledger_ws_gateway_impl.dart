import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../domain/entities/services/service_w_s_database.dart';
import '../../domain/gateway/ledger_ws_gateway.dart';

/// Gateway WS que delega en el servicio persistente.
class LedgerWsGatewayImpl implements LedgerWsGateway {
  LedgerWsGatewayImpl(this._service);
  final ServiceWSDatabase _service;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> saveLedger(
    Map<String, dynamic> ledger,
  ) {
    return _service.write(LedgerWsGateway.ledgerPath, ledger);
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

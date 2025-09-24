import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Contrato del Gateway para acceder al ledger del usuario mediante WebSocket.
///
/// Este gateway actúa como adaptador entre la infraestructura WebSocket (`ServiceWSDatabase`)
/// y la capa de dominio, permitiendo sincronizar el `LedgerModel` en tiempo real.
abstract class LedgerWsGateway {
  /// Ruta fija en WebSocket para el ledger.
  static const String ledgerPath = 'okane/ledgers/';

  /// Envía una versión nueva del ledger al backend.
  ///
  /// Retorna un `Right<void>` si el envío fue exitoso, o un `Left<ErrorItem>` si hubo error.
  Future<Either<ErrorItem, Map<String, dynamic>>> saveLedger(
    Map<String, dynamic> ledger,
  );

  /// Recupera la última versión persistida del ledger del usuario.
  ///
  /// Retorna un `Right<Map<String, dynamic>` si fue exitoso, o un `Left<ErrorItem>` si falló.
  Future<Either<ErrorItem, Map<String, dynamic>>> fetchLedger();

  /// Devuelve un stream que emite actualizaciones remotas al ledger.
  ///
  /// El stream emite objetos `Map<String, dynamic>` o un `ErrorItem` si falla la conexión.
  Stream<Either<ErrorItem, Map<String, dynamic>>> onLedgerUpdated();
}

import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Contrato del repositorio para manipular el ledger del usuario.
///
/// Esta capa intermedia encapsula las reglas de aplicación que operan sobre
/// el `LedgerModel` y delega la sincronización remota al `LedgerWsGateway`.
abstract class LedgerRepository {
  /// Agrega un ingreso al ledger y sincroniza los cambios.
  ///
  /// Retorna el nuevo estado del ledger o un error si falla.
  Future<Either<ErrorItem, LedgerModel>> addIncome(
    FinancialMovementModel income,
  );

  /// Agrega un egreso al ledger y sincroniza los cambios.
  ///
  /// Falla si el egreso es mayor al balance.
  Future<Either<ErrorItem, LedgerModel>> addExpense(
    FinancialMovementModel expense,
  );

  /// Carga el estado actual del ledger desde el backend.
  Future<Either<ErrorItem, LedgerModel>> getLedger();

  /// Escucha cambios remotos del ledger en tiempo real.
  Stream<Either<ErrorItem, LedgerModel>> subscribeToLedgerChanges();
}

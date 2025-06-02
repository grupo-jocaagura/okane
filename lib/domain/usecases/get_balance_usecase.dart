import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Caso de uso para obtener el balance disponible del usuario.
class GetBalanceUseCase {
  int execute(LedgerModel ledger) {
    return MoneyUtils.totalAmount(ledger.incomeLedger) -
        MoneyUtils.totalAmount(ledger.expenseLedger);
  }
}

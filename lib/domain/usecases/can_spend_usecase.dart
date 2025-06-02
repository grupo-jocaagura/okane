import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../entities/usecase.dart';

/// Caso de uso para validar si el usuario puede gastar un monto determinado.
///
/// Este caso de uso trabaja localmente sobre una instancia del modelo.
class CanSpendUseCase implements Usecase {
  bool execute(LedgerModel ledger, int amount) {
    final int balance = MoneyUtils.totalAmount(ledger.incomeLedger) -
        MoneyUtils.totalAmount(ledger.expenseLedger);
    return balance >= amount;
  }
}

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domain/error_item.dart';
import '../utils/money_utils.dart';

class BlocUserLedger extends BlocModule {
  final BlocGeneral<List<FinancialMovementModel>> incomeLedger =
      BlocGeneral<List<FinancialMovementModel>>(<FinancialMovementModel>[]);

  final BlocGeneral<List<FinancialMovementModel>> expenseLedger =
      BlocGeneral<List<FinancialMovementModel>>(<FinancialMovementModel>[]);

  int get sumIncomeLedger => MoneyUtils.sumFromLedger(incomeLedger.value);
  int get sumExpenseLedger => MoneyUtils.sumFromLedger(expenseLedger.value);

  int get balance => sumIncomeLedger - sumExpenseLedger;

  bool canISpendIt(int amount) => balance >= amount;

  // Registrar un ingreso
  Either<ErrorItem, List<FinancialMovementModel>> addIncome(
    FinancialMovementModel movement,
  ) {
    if (movement.amount <= 0) {
      return Left<ErrorItem, List<FinancialMovementModel>>(
        ErrorItem(
          title: 'Monto inválido',
          code: 'INVALID_AMOUNT',
          description: 'El monto debe ser mayor a 0.',
          meta: <String, dynamic>{'amount': movement.amount},
        ),
      );
    }

    final List<FinancialMovementModel> updatedLedger =
        List<FinancialMovementModel>.from(incomeLedger.value)..add(movement);

    incomeLedger.value = updatedLedger;
    return Right<ErrorItem, List<FinancialMovementModel>>(updatedLedger);
  }

  Either<ErrorItem, List<FinancialMovementModel>> addExpense(
    FinancialMovementModel movement,
  ) {
    if (movement.amount <= 0) {
      return Left<ErrorItem, List<FinancialMovementModel>>(
        ErrorItem(
          title: 'Monto inválido',
          code: 'INVALID_AMOUNT',
          description: 'El monto debe ser mayor a 0.',
          meta: <String, dynamic>{'amount': movement.amount},
        ),
      );
    }
    if (!canISpendIt(movement.amount)) {
      return Left<ErrorItem, List<FinancialMovementModel>>(
        ErrorItem(
          title: 'Saldo insuficiente',
          code: 'INSUFFICIENT_BALANCE',
          description: 'El egreso supera el saldo disponible.',
          meta: <String, dynamic>{
            'amount': movement.amount,
            'balance': balance,
          },
        ),
      );
    }

    final List<FinancialMovementModel> updatedLedger =
        List<FinancialMovementModel>.from(expenseLedger.value)..add(movement);

    expenseLedger.value = updatedLedger;
    return Right<ErrorItem, List<FinancialMovementModel>>(updatedLedger);
  }

  @override
  void dispose() {
    incomeLedger.dispose();
    expenseLedger.dispose();
  }

  @override
  String toString() {
    return '''
✔ Ingresos: ${MoneyUtils.toCop(sumIncomeLedger)}
💸 Gastos: ${MoneyUtils.toCop(sumExpenseLedger)}
📒 Balance: ${MoneyUtils.toCop(balance)}
''';
  }
}

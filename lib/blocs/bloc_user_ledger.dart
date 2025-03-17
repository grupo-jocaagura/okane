import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domain/error_item.dart';
import '../utils/money_utils.dart';

/// `BlocUserLedger` gestiona los ingresos y egresos financieros del usuario.
///
/// Esta clase extiende `BlocModule` y encapsula la lógica para manejar registros
/// de movimientos financieros, permitiendo agregar ingresos y gastos,
/// calcular el balance y verificar si hay suficiente saldo para gastar.
///
/// ## Propiedades:
/// - `incomeLedger`: Administra la lista de ingresos.
/// - `expenseLedger`: Administra la lista de egresos.
/// - `sumIncomeLedger`: Retorna la suma total de ingresos.
/// - `sumExpenseLedger`: Retorna la suma total de egresos.
/// - `balance`: Calcula el balance restando egresos de ingresos.
/// - `canISpendIt(int amount)`: Indica si hay suficiente saldo para un gasto.
///
/// ## Métodos:
/// - `addIncome(FinancialMovementModel movement)`: Agrega un ingreso.
/// - `addExpense(FinancialMovementModel movement)`: Agrega un gasto.
/// - `dispose()`: Libera los recursos de los BLoCs.
///
/// ### Ejemplo de uso:
/// ```dart
/// void main() {
///   final ledger = BlocUserLedger();
///
///   final income = FinancialMovementModel(amount: 5000, description: 'Salario');
///   final expense = FinancialMovementModel(amount: 2000, description: 'Alquiler');
///
///   ledger.addIncome(income);
///   ledger.addExpense(expense);
///
///   print('Balance actual: ${ledger.balance}'); // 3000
///
///   if (ledger.canISpendIt(1000)) {
///     print('Puedes gastar 1000');
///   } else {
///     print('No tienes suficiente saldo');
///   }
///
///   ledger.dispose();
/// }
/// ```
class BlocUserLedger extends BlocModule {
  /// Lista de ingresos registrados.
  final BlocGeneral<List<FinancialMovementModel>> incomeLedger =
      BlocGeneral<List<FinancialMovementModel>>(<FinancialMovementModel>[]);

  /// Lista de egresos registrados.
  final BlocGeneral<List<FinancialMovementModel>> expenseLedger =
      BlocGeneral<List<FinancialMovementModel>>(<FinancialMovementModel>[]);

  /// Retorna la suma total de los ingresos.
  int get sumIncomeLedger => MoneyUtils.sumFromLedger(incomeLedger.value);

  /// Retorna la suma total de los egresos.
  int get sumExpenseLedger => MoneyUtils.sumFromLedger(expenseLedger.value);

  /// Calcula el balance general como ingresos menos egresos.
  int get balance => sumIncomeLedger - sumExpenseLedger;

  /// Verifica si se puede gastar una cantidad específica sin quedar en saldo negativo.
  bool canISpendIt(int amount) => balance >= amount;

  /// Agrega un ingreso al ledger de ingresos.
  ///
  /// Retorna un `Right` con la lista actualizada si el monto es válido,
  /// de lo contrario, devuelve un `Left` con un `ErrorItem`.
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

  /// Agrega un gasto al ledger de egresos.
  ///
  /// Retorna un `Right` con la lista actualizada si el monto es válido y hay saldo suficiente.
  /// En caso contrario, devuelve un `Left` con un `ErrorItem`.
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

  /// Libera los recursos asociados a los BLoCs de ingresos y egresos.
  @override
  void dispose() {
    incomeLedger.dispose();
    expenseLedger.dispose();
  }

  /// Retorna una representación en texto del estado actual del ledger.
  @override
  String toString() {
    return '''
✔ Ingresos: ${MoneyUtils.toCop(sumIncomeLedger)}
💸 Gastos: ${MoneyUtils.toCop(sumExpenseLedger)}
📒 Balance: ${MoneyUtils.toCop(balance)}
''';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:okane/blocs/bloc_user_ledger.dart';
import 'package:okane/domain/error_item.dart';

void main() {
  late BlocUserLedger ledger;

  setUp(() {
    ledger = BlocUserLedger();
  });

  group('BlocUserLedger Tests', () {
    test('El balance inicial debe ser 0', () {
      expect(ledger.balance, 0);
    });

    test('Debe registrar un ingreso válido', () {
      final FinancialMovementModel movement = FinancialMovementModel(
        id: '1',
        amount: 10000, // 100 COP
        date: DateTime.now(),
        concept: 'Salario',
        category: 'Ingreso',
        createdAt: DateTime.now(),
      );

      final Either<ErrorItem, List<FinancialMovementModel>> result =
          ledger.addIncome(movement);

      expect(result.isRight, true);
      expect(ledger.sumIncomeLedger, 10000);
      expect(ledger.balance, 10000);
    });

    test('Debe registrar un egreso válido si hay saldo suficiente', () {
      final FinancialMovementModel income = FinancialMovementModel(
        id: '1',
        amount: 20000, // 200 COP
        date: DateTime.now(),
        concept: 'Pago',
        category: 'Ingreso',
        createdAt: DateTime.now(),
      );

      ledger.addIncome(income);

      final FinancialMovementModel expense = FinancialMovementModel(
        id: '2',
        amount: 15000, // 150 COP
        date: DateTime.now(),
        concept: 'Compra',
        category: 'Egreso',
        createdAt: DateTime.now(),
      );

      final Either<ErrorItem, List<FinancialMovementModel>> result =
          ledger.addExpense(expense);

      expect(result.isRight, true);
      expect(ledger.sumExpenseLedger, 15000);
      expect(ledger.balance, 5000);
    });

    test(
        'Debe retornar un error al registrar un ingreso con monto 0 o negativo',
        () {
      final FinancialMovementModel invalidIncome = FinancialMovementModel(
        id: '3',
        amount: 0,
        date: DateTime.now(),
        concept: 'Prueba',
        category: 'Ingreso',
        createdAt: DateTime.now(),
      );

      final Either<ErrorItem, List<FinancialMovementModel>> result =
          ledger.addIncome(invalidIncome);

      expect(result.isLeft, true);
      final ErrorItem? error =
          result.when((ErrorItem error) => error, (_) => null);

      expect(
        error,
        isA<ErrorItem>()
            .having((ErrorItem e) => e.code, 'Código', 'INVALID_AMOUNT')
            .having(
              (ErrorItem e) => e.description,
              'Descripción',
              'El monto debe ser mayor a 0.',
            ),
      );
    });

    test('Debe retornar un error al registrar un egreso con monto 0 o negativo',
        () {
      final FinancialMovementModel invalidExpense = FinancialMovementModel(
        id: '4',
        amount: -10000, // -100 COP
        date: DateTime.now(),
        concept: 'Prueba',
        category: 'Egreso',
        createdAt: DateTime.now(),
      );

      final Either<ErrorItem, List<FinancialMovementModel>> result =
          ledger.addExpense(invalidExpense);

      expect(result.isLeft, true);
      final ErrorItem? error =
          result.when((ErrorItem error) => error, (_) => null);

      expect(
        error,
        isA<ErrorItem>()
            .having((ErrorItem e) => e.code, 'Código', 'INVALID_AMOUNT')
            .having(
              (ErrorItem e) => e.description,
              'Descripción',
              'El monto debe ser mayor a 0.',
            ),
      );
    });

    test('Debe retornar un error al intentar gastar más de lo disponible', () {
      final FinancialMovementModel expense = FinancialMovementModel(
        id: '5',
        amount: 50000, // 500 COP
        date: DateTime.now(),
        concept: 'Renta',
        category: 'Egreso',
        createdAt: DateTime.now(),
      );

      final Either<ErrorItem, List<FinancialMovementModel>> result =
          ledger.addExpense(expense);

      expect(result.isLeft, true);
      final ErrorItem? error =
          result.when((ErrorItem error) => error, (_) => null);

      expect(
        error,
        isA<ErrorItem>()
            .having((ErrorItem e) => e.code, 'Código', 'INSUFFICIENT_BALANCE')
            .having(
              (ErrorItem e) => e.description,
              'Descripción',
              'El egreso supera el saldo disponible.',
            ),
      );
    });

    test('Debe mostrar la información correctamente en toString()', () {
      final FinancialMovementModel income = FinancialMovementModel(
        id: '6',
        amount: 30000, // 300 COP
        date: DateTime.now(),
        concept: 'Salario',
        category: 'Ingreso',
        createdAt: DateTime.now(),
      );

      ledger.addIncome(income);

      expect(ledger.toString(), contains(r'✔ Ingresos: $300.00'));
      expect(ledger.toString(), contains(r'💸 Gastos: $0.00'));
      expect(ledger.toString(), contains(r'📒 Balance: $300.00'));
    });
  });
}

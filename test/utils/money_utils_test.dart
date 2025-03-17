import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:okane/utils/money_utils.dart';

void main() {
  group('MoneyUtils Tests', () {
    test(r'toCop convierte correctamente 100 centavos en $1.00', () {
      expect(MoneyUtils.toCop(100), r'$1.00');
    });

    test(r'toCop convierte correctamente 123456 centavos en $1,234.56', () {
      expect(MoneyUtils.toCop(123456), r'$1234.56');
    });

    test(r'toCop convierte correctamente 0 centavos en $0.00', () {
      expect(MoneyUtils.toCop(0), r'$0.00');
    });

    test('toCop maneja correctamente valores negativos', () {
      expect(MoneyUtils.toCop(-2500), r'$-25.00');
    });

    test('sumFromLedger retorna 0 si la lista está vacía', () {
      final List<FinancialMovementModel> emptyList = <FinancialMovementModel>[];
      expect(MoneyUtils.sumFromLedger(emptyList), 0);
    });

    test('sumFromLedger suma correctamente múltiples valores positivos', () {
      final List<FinancialMovementModel> movements = <FinancialMovementModel>[
        FinancialMovementModel(
          id: '1',
          amount: 10000, // 100 COP
          date: DateTime.now(),
          concept: 'Ingreso 1',
          category: 'Ingreso',
          createdAt: DateTime.now(),
        ),
        FinancialMovementModel(
          id: '2',
          amount: 25000, // 250 COP
          date: DateTime.now(),
          concept: 'Ingreso 2',
          category: 'Ingreso',
          createdAt: DateTime.now(),
        ),
      ];
      expect(MoneyUtils.sumFromLedger(movements), 35000);
    });

    test('sumFromLedger maneja correctamente valores negativos', () {
      final List<FinancialMovementModel> movements = <FinancialMovementModel>[
        FinancialMovementModel(
          id: '1',
          amount: 20000, // 200 COP
          date: DateTime.now(),
          concept: 'Ingreso',
          category: 'Ingreso',
          createdAt: DateTime.now(),
        ),
        FinancialMovementModel(
          id: '2',
          amount: -5000, // -50 COP
          date: DateTime.now(),
          concept: 'Egreso',
          category: 'Egreso',
          createdAt: DateTime.now(),
        ),
      ];
      expect(MoneyUtils.sumFromLedger(movements), 15000);
    });
  });
}

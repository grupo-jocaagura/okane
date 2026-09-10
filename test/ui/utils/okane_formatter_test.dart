import 'package:flutter_test/flutter_test.dart';
import 'package:okane/ui/utils/okane_formatter.dart';

void main() {
  group('OkaneFormatter.moneyFormatter', () {
    test('formats zero', () {
      expect(OkaneFormatter.moneyFormatter(0), r'$ 0,00');
    });

    test('formats hundreds', () {
      expect(OkaneFormatter.moneyFormatter(500), r'$ 500,00');
    });

    test('formats thousands with dot', () {
      expect(OkaneFormatter.moneyFormatter(1000), r'$ 1.000,00');
    });

    test('formats hundreds of thousands', () {
      expect(OkaneFormatter.moneyFormatter(128500), r'$ 128.500,00');
    });

    test('formats millions using current Okane convention', () {
      expect(OkaneFormatter.moneyFormatter(1000000), r"$ 1'000.000,00");
    });

    test('formats large values using alternating separators', () {
      expect(
        OkaneFormatter.moneyFormatter(1000000000000),
        r"$ 1'000.000'000.000,00",
      );
    });

    test('formats negative values', () {
      expect(OkaneFormatter.moneyFormatter(-1234567.8), r"$ -1'234.567,80");
    });

    test('rounds to two decimal places', () {
      expect(OkaneFormatter.moneyFormatter(1234.567), r'$ 1.234,57');
    });
  });

  group('OkaneFormatter.intMoneyFormatter', () {
    test('delegates integer formatting consistently', () {
      expect(
        OkaneFormatter.intMoneyFormatter(128500),
        OkaneFormatter.moneyFormatter(128500),
      );
    });

    test('formats integer amount', () {
      expect(OkaneFormatter.intMoneyFormatter(2000000), r"$ 2'000.000,00");
    });
  });

  group('OkaneFormatter.dateFormatter', () {
    test('formats date as dd/MM/yyyy', () {
      expect(OkaneFormatter.dateFormatter(DateTime(2026, 8, 9)), '09/08/2026');
    });

    test('pads single digit day and month', () {
      expect(OkaneFormatter.dateFormatter(DateTime(2026, 1, 2)), '02/01/2026');
    });
  });
}

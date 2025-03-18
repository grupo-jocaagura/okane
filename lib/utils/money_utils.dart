import 'package:jocaagura_domain/jocaagura_domain.dart';

class MoneyUtils {
  static String toCop(int cents) {
    final double amount = cents / 100;
    return '\$${amount.toStringAsFixed(2)}';
  }

  static int sumFromLedger(
    List<FinancialMovementModel> financialMovementsList,
  ) {
    return financialMovementsList.fold(
      0,
      (int sum, FinancialMovementModel item) => sum + item.amount,
    );
  }
}

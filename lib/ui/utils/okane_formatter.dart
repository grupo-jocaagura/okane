/// # OkaneFormater
/// Formatea valores monetarios al estilo **CO**:
/// - Miles con `.`
/// - En límites de millón (cada 6 dígitos desde la derecha) alterna con `'`
/// - Separador decimal `,` y siempre 2 decimales
///
/// ## Ejemplos de uso (MD)
/// ```dart
/// OkaneFormater.moneyFormatter(0);                    // "$ 0,00"
/// OkaneFormater.moneyFormatter(1000);                 // "$ 1.000,00"
/// OkaneFormater.moneyFormatter(100000);               // "$ 100.000,00"
/// OkaneFormater.moneyFormatter(1000000);              // "$ 1'000.000,00"
/// OkaneFormater.moneyFormatter(1000000000000);        // "$ 1'000.000'000.000,00"
/// OkaneFormater.moneyFormatter(-1234567.8);           // "$ -1'234.567,80"
/// ```
class OkaneFormatter {
  const OkaneFormatter();

  static String intMoneyFormatter(int value) {
    return moneyFormatter(value.toDouble());
  }

  /// Devuelve un string con formato tipo: "$ 1'000.000,00"
  static String moneyFormatter(double value) {
    final bool isNegative = value < 0;
    final String fixed = value.abs().toStringAsFixed(2);

    final int dotIndex = fixed.indexOf('.');
    final String integer = dotIndex == -1
        ? fixed
        : fixed.substring(0, dotIndex);
    final String decimals =
        (dotIndex == -1 ? '00' : fixed.substring(dotIndex + 1)).padLeft(2, '0');

    final List<String> triadsRightToLeft = <String>[];
    for (int i = integer.length; i > 0; i -= 3) {
      final int start = (i - 3) < 0 ? 0 : (i - 3);
      triadsRightToLeft.add(integer.substring(start, i));
    }

    String formattedInt = triadsRightToLeft.isEmpty
        ? '0'
        : triadsRightToLeft[0];
    for (int k = 1; k < triadsRightToLeft.length; k++) {
      final String sep = (k.isOdd) ? '.' : "'";
      formattedInt = '${triadsRightToLeft[k]}$sep$formattedInt';
    }

    // Armar resultado final
    return '\$ ${isNegative ? '-' : ''}$formattedInt,$decimals';
  }

  static String dateFormatter(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString(); // últimos dos dígitos
    return '$day/$month/$year';
  }
}

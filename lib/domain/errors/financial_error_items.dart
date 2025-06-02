import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Define errores específicos relacionados con operaciones financieras.
abstract class FinancialErrorItems {
  static ErrorItem invalidAmount(int amount) => ErrorItem(
        title: 'Monto inválido',
        description: 'El monto debe ser mayor a 0. Valor recibido: $amount.',
        code: 'INVALID_AMOUNT',
        meta: <String, dynamic>{'amount': amount},
      );

  static ErrorItem insufficientBalance(int balance, int requested) => ErrorItem(
        title: 'Saldo insuficiente',
        description:
            'El egreso solicitado supera el saldo disponible. Intentaste gastar $requested pero solo tienes $balance.',
        code: 'INSUFFICIENT_BALANCE',
        meta: <String, dynamic>{
          'balance': balance,
          'requested': requested,
        },
      );

  static ErrorItem invalidLedgerFormat() => const ErrorItem(
        title: 'Formato de libro inválido',
        description:
            'El formato de datos del LedgerModel recibido no es válido o no pudo ser convertido.',
        code: 'LEDGER_FORMAT_ERROR',
      );
}

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../domain/errors/financial_error_items.dart';
import '../../domain/gateway/ledger_ws_gateway.dart';
import '../../domain/repositories/ledger_reporitory.dart';

/// Implementación del repositorio de dominio para manipular el `LedgerModel`.
///
/// Se encarga de traducir datos (`Map<String, dynamic>`) a modelos y delegar la lógica de validación.
class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(this._gateway);
  final LedgerWsGateway _gateway;

  @override
  Future<Either<ErrorItem, LedgerModel>> addIncome(
    FinancialMovementModel movement,
  ) async {
    final Either<ErrorItem, Map<String, dynamic>> readResult =
        await _gateway.fetchLedger();
    return readResult.when(
      (ErrorItem error) => Left<ErrorItem, LedgerModel>(error),
      (Map<String, dynamic> json) {
        try {
          final LedgerModel current = LedgerModel.fromJson(json);
          if (movement.amount <= 0) {
            return Left<ErrorItem, LedgerModel>(
              FinancialErrorItems.invalidAmount(movement.amount),
            );
          }

          final List<FinancialMovementModel> updatedIncome =
              List<FinancialMovementModel>.from(current.incomeLedger)
                ..add(movement);

          final LedgerModel updated =
              current.copyWith(incomeLedger: updatedIncome);
          return _saveAndReturn(updated);
        } catch (_) {
          return Left<ErrorItem, LedgerModel>(
            FinancialErrorItems.invalidLedgerFormat(),
          );
        }
      },
    );
  }

  @override
  Future<Either<ErrorItem, LedgerModel>> addExpense(
    FinancialMovementModel movement,
  ) async {
    final Either<ErrorItem, Map<String, dynamic>> readResult =
        await _gateway.fetchLedger();
    return readResult.when(
      (ErrorItem error) => Left<ErrorItem, LedgerModel>(error),
      (Map<String, dynamic> json) {
        try {
          final LedgerModel current = LedgerModel.fromJson(json);
          final int balance = MoneyUtils.totalAmount(current.incomeLedger) -
              MoneyUtils.totalAmount(current.expenseLedger);

          if (movement.amount <= 0) {
            return Left<ErrorItem, LedgerModel>(
              FinancialErrorItems.invalidAmount(movement.amount),
            );
          }

          if (balance < movement.amount) {
            return Left<ErrorItem, LedgerModel>(
              FinancialErrorItems.insufficientBalance(balance, movement.amount),
            );
          }

          final List<FinancialMovementModel> updatedExpenses =
              List<FinancialMovementModel>.from(current.expenseLedger)
                ..add(movement);

          final LedgerModel updated =
              current.copyWith(expenseLedger: updatedExpenses);
          return _saveAndReturn(updated);
        } catch (_) {
          return Left<ErrorItem, LedgerModel>(
            FinancialErrorItems.invalidLedgerFormat(),
          );
        }
      },
    );
  }

  @override
  Future<Either<ErrorItem, LedgerModel>> getLedger() async {
    final Either<ErrorItem, Map<String, dynamic>> result =
        await _gateway.fetchLedger();
    return result.when(
      (ErrorItem error) => Left<ErrorItem, LedgerModel>(error),
      (Map<String, dynamic> json) {
        try {
          return Right<ErrorItem, LedgerModel>(LedgerModel.fromJson(json));
        } catch (_) {
          return Left<ErrorItem, LedgerModel>(
            FinancialErrorItems.invalidLedgerFormat(),
          );
        }
      },
    );
  }

  @override
  Stream<Either<ErrorItem, LedgerModel>> subscribeToLedgerChanges() {
    return _gateway
        .onLedgerUpdated()
        .map((Either<ErrorItem, Map<String, dynamic>> event) {
      return event.when(
        (ErrorItem error) => Left<ErrorItem, LedgerModel>(error),
        (Map<String, dynamic> json) {
          try {
            return Right<ErrorItem, LedgerModel>(LedgerModel.fromJson(json));
          } catch (_) {
            return Left<ErrorItem, LedgerModel>(
              FinancialErrorItems.invalidLedgerFormat(),
            );
          }
        },
      );
    });
  }

  Future<Either<ErrorItem, LedgerModel>> _saveAndReturn(
    LedgerModel updated,
  ) async {
    final Either<ErrorItem, void> saveResult =
        await _gateway.saveLedger(updated.toJson());
    return saveResult.when(
      (ErrorItem error) => Left<ErrorItem, LedgerModel>(error),
      (_) => Right<ErrorItem, LedgerModel>(updated),
    );
  }
}

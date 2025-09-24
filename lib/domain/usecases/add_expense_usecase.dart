import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../entities/usecase.dart';
import '../repositories/ledger_reporitory.dart';

/// Caso de uso para agregar un gasto al ledger del usuario.
class AddExpenseUseCase implements Usecase {
  const AddExpenseUseCase(this.repository);
  final LedgerRepository repository;

  Future<Either<ErrorItem, LedgerModel>> execute(
    FinancialMovementModel movement,
  ) {
    return repository.addExpense(movement);
  }
}

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../entities/usecase.dart';
import '../repositories/ledger_reporitory.dart';

/// Caso de uso para agregar un ingreso al ledger del usuario.
class AddIncomeUseCase implements Usecase {
  const AddIncomeUseCase(this.repository);
  final LedgerRepository repository;

  Future<Either<ErrorItem, LedgerModel>> execute(
    FinancialMovementModel movement,
  ) {
    return repository.addIncome(movement);
  }
}

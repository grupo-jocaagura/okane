import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../entities/usecase.dart';
import '../repositories/ledger_reporitory.dart';

/// Caso de uso para consultar el estado actual del ledger del usuario.
class GetLedgerUseCase implements Usecase {
  const GetLedgerUseCase(this.repository);
  final LedgerRepository repository;

  Future<Either<ErrorItem, LedgerModel>> execute() {
    return repository.getLedger();
  }
}

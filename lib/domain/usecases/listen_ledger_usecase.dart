import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../entities/usecase.dart';
import '../repositories/ledger_reporitory.dart';

/// Caso de uso para escuchar actualizaciones remotas del ledger.
class ListenLedgerUseCase implements Usecase {
  const ListenLedgerUseCase(this.repository);
  final LedgerRepository repository;

  Stream<Either<ErrorItem, LedgerModel>> execute() {
    return repository.subscribeToLedgerChanges();
  }
}

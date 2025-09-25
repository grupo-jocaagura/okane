import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../../domain/entities/services/service_w_s_database.dart';
import '../../domain/gateway/ledger_ws_gateway.dart';

/// Servicio WS simulado para pruebas en Okane.
///
/// Soporta un único ledger por nombre bajo el path `okane/{ledger.nameOfLedger}`.
class FakeServiceWSDatabase implements ServiceWSDatabase {
  static ErrorItem notFound(String path) => ErrorItem(
    title: 'Dato no encontrado',
    description: 'No existe ledger en $path',
    code: 'NOT_FOUND',
  );

  final BlocGeneral<Either<ErrorItem, Map<String, dynamic>>> _ledgerStream =
      BlocGeneral<Either<ErrorItem, Map<String, dynamic>>>(
        Left<ErrorItem, Map<String, dynamic>>(notFound('okane/default')),
      );

  Map<String, dynamic> _ledgerJson = demoLedgerModel()
      .copyWith(nameOfLedger: defaultOkaneLedger.nameOfLedger)
      .toJson();

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    String path,
    Map<String, dynamic> data,
  ) async {
    if (!path.startsWith(LedgerWsGateway.ledgerPath)) {
      _ledgerStream.value = Left<ErrorItem, Map<String, dynamic>>(
        notFound(path),
      );
      return _ledgerStream.value;
    }

    _ledgerJson = data;
    _ledgerStream.value = Right<ErrorItem, Map<String, dynamic>>(data);
    return _ledgerStream.value;
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String path) async {
    if (path.startsWith(LedgerWsGateway.ledgerPath)) {
      return Right<ErrorItem, Map<String, dynamic>>(_ledgerJson);
    }
    return Left<ErrorItem, Map<String, dynamic>>(notFound(path));
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> onValue(String path) {
    return _ledgerStream.stream;
  }

  /// Limpia el estado simulado y reinicia el stream con error.
  void reset() {
    _ledgerJson = defaultOkaneLedger.toJson();
    _ledgerStream.value = Left<ErrorItem, Map<String, dynamic>>(
      notFound('okane/default'),
    );
  }

  void dispose() {
    _ledgerStream.dispose();
  }
}

/// Builds a lightweight demo ledger for 2024 in Colombia.
///
/// - Income: monthly salary (25th of each month).
/// - Expenses: rent (1st), utilities (15th), groceries (7th), transport pass (10th),
///   entertainment (20th).
///
/// The dataset is intentionally **small** (one record per category per month)
/// to keep samples/snippets fast while still looking realistic.
///
/// Example:
/// ```dart
/// void main() {
///   final LedgerModel ledger = demoLedgerModel();
///   print(ledger.incomeLedger.length);  // 12
///   print(ledger.expenseLedger.length); // 12 * 5 = 60
/// }
/// ```
LedgerModel demoLedgerModel({
  String region = 'Colombia',
  int salaryMonthly = 3500000,
  int rentMonthly = 1500000,
  int utilitiesMonthly = 250000,
  int groceriesMonthly = 260000,
  int transportMonthly = 160000,
  int entertainmentMonthly = 100000,
}) {
  final List<FinancialMovementModel> incomes = defaultIncomeLedger2024(
    salaryMonthly: salaryMonthly,
  );
  final List<FinancialMovementModel> expenses = defaultExpenseLedger2024(
    rentMonthly: rentMonthly,
    utilitiesMonthly: utilitiesMonthly,
    groceriesMonthly: groceriesMonthly,
    transportMonthly: transportMonthly,
    entertainmentMonthly: entertainmentMonthly,
  );

  return LedgerModel(
    incomeLedger: List<FinancialMovementModel>.unmodifiable(incomes),
    expenseLedger: List<FinancialMovementModel>.unmodifiable(expenses),
    nameOfLedger: 'Income',
  );
}

/// Minimal income ledger for 2024: one salary entry per month (25th).
List<FinancialMovementModel> defaultIncomeLedger2024({
  required int salaryMonthly,
}) {
  final List<FinancialMovementModel> list = <FinancialMovementModel>[];
  for (int m = 1; m <= 12; m++) {
    final DateTime d = DateTime(2024, m, 25);
    list.add(
      FinancialMovementModel(
        id: 'inc-salary-$m',
        amount: salaryMonthly,
        date: d,
        concept: 'Salario',
        detailedDescription: 'Salario mensual',
        category: 'Salario',
        createdAt: d,
      ),
    );
  }
  return list;
}

/// Minimal expense ledger for 2024: one record per category per month.
List<FinancialMovementModel> defaultExpenseLedger2024({
  required int rentMonthly,
  required int utilitiesMonthly,
  required int groceriesMonthly,
  required int transportMonthly,
  required int entertainmentMonthly,
}) {
  final List<FinancialMovementModel> list = <FinancialMovementModel>[];
  for (int m = 1; m <= 12; m++) {
    // 1) Arriendo (día 1)
    final DateTime rentDate = DateTime(2024, m);
    list.add(
      FinancialMovementModel(
        id: 'exp-rent-$m',
        amount: rentMonthly,
        date: rentDate,
        concept: 'Arriendo',
        detailedDescription: 'Arriendo mensual',
        category: 'Arriendo',
        createdAt: rentDate,
      ),
    );

    // 2) Servicios (día 15)
    final DateTime utilDate = DateTime(2024, m, 15);
    list.add(
      FinancialMovementModel(
        id: 'exp-utils-$m',
        amount: utilitiesMonthly,
        date: utilDate,
        concept: 'Servicios',
        detailedDescription: 'Luz/agua/internet',
        category: 'Servicios',
        createdAt: utilDate,
      ),
    );

    // 3) Mercado (día 7)
    final DateTime grocDate = DateTime(2024, m, 7);
    list.add(
      FinancialMovementModel(
        id: 'exp-groceries-$m',
        amount: groceriesMonthly,
        date: grocDate,
        concept: 'Mercado',
        detailedDescription: 'Supermercado mensual',
        category: 'Mercado',
        createdAt: grocDate,
      ),
    );

    // 4) Transporte (día 10)
    final DateTime trnDate = DateTime(2024, m, 10);
    list.add(
      FinancialMovementModel(
        id: 'exp-transport-$m',
        amount: transportMonthly,
        date: trnDate,
        concept: 'Transporte',
        detailedDescription: 'Abono/recargas',
        category: 'Transporte',
        createdAt: trnDate,
      ),
    );

    // 5) Entretenimiento (día 20)
    final DateTime entDate = DateTime(2024, m, 20);
    list.add(
      FinancialMovementModel(
        id: 'exp-entertainment-$m',
        amount: entertainmentMonthly,
        date: entDate,
        concept: 'Entretenimiento',
        detailedDescription: 'Ocio mensual',
        category: 'Entretenimiento',
        createdAt: entDate,
      ),
    );
  }
  return list;
}

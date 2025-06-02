import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:okane/domain/errors/financial_error_items.dart';
import 'package:okane/infrastructure/gateways/ledger_ws_gateway_impl.dart';
import 'package:okane/infrastructure/repositories/ledger_repository_impl.dart';
import 'package:okane/infrastructure/services/fake_service_w_s_database.dart';

void main() {
  late LedgerRepositoryImpl repository;
  late FakeServiceWSDatabase fakeService;

  const String path = 'okane/defaultOkane';

  final Map<String, dynamic> validLedger = <String, dynamic>{
    'nameOfLedger': 'defaultOkane',
    'incomeLedger': <Map<String, dynamic>>[],
    'expenseLedger': <Map<String, dynamic>>[],
  };

  final FinancialMovementModel income = FinancialMovementModel(
    id: 'i001',
    amount: 1000,
    concept: 'Salary',
    date: DateTime.now(),
    createdAt: DateTime.now(),
    category: 'Income',
    detailedDescription: 'Monthly salary',
  );

  final FinancialMovementModel invalid = income.copyWith(amount: 0);

  final FinancialMovementModel overExpense = income.copyWith(amount: 5000);

  setUp(() async {
    fakeService = FakeServiceWSDatabase();
    final LedgerWsGatewayImpl gateway = LedgerWsGatewayImpl(fakeService);
    repository = LedgerRepositoryImpl(gateway);
    await fakeService.write(path, validLedger);
  });

  tearDown(() {
    fakeService.dispose();
  });

  test('getLedger retorna un modelo válido', () async {
    final Either<ErrorItem, LedgerModel> result = await repository.getLedger();
    expect(result.isRight, true);
    expect(
      result.when((ErrorItem err) => null, (LedgerModel m) => m.nameOfLedger),
      'defaultOkane',
    );
  });

  test('addIncome agrega movimiento correctamente', () async {
    final Either<ErrorItem, LedgerModel> result =
        await repository.addIncome(income);
    expect(result.isRight, true);
    expect(
      result.when(
        (ErrorItem err) => null,
        (LedgerModel m) => m.incomeLedger.length,
      ),
      1,
    );
  });

  test('addIncome con monto inválido retorna error', () async {
    final Either<ErrorItem, LedgerModel> result =
        await repository.addIncome(invalid);
    expect(result.isLeft, true);
    expect(
      result.when((ErrorItem err) => err.code, (_) => ''),
      FinancialErrorItems.invalidAmount(0).code,
    );
  });

  test('addExpense exitoso cuando hay saldo suficiente', () async {
    await repository.addIncome(income);
    final FinancialMovementModel expense = income.copyWith(
      id: 'e001',
      amount: 800,
      concept: 'Gasto',
      category: 'Expense',
    );
    final Either<ErrorItem, LedgerModel> result =
        await repository.addExpense(expense);
    expect(result.isRight, true);
    expect(
      result.when(
        (ErrorItem err) => null,
        (LedgerModel m) => m.expenseLedger.length,
      ),
      1,
    );
  });

  test('addExpense con monto inválido retorna error', () async {
    final Either<ErrorItem, LedgerModel> result =
        await repository.addExpense(invalid);
    expect(result.isLeft, true);
    expect(
      result.when((ErrorItem err) => err.code, (_) => ''),
      FinancialErrorItems.invalidAmount(0).code,
    );
  });

  test('addExpense sin saldo suficiente retorna error de balance', () async {
    final Either<ErrorItem, LedgerModel> result =
        await repository.addExpense(overExpense);
    expect(result.isLeft, true);
    expect(
      result.when((ErrorItem err) => err.code, (_) => ''),
      FinancialErrorItems.insufficientBalance(0, 5000).code,
    );
  });

  test('subscribeToLedgerChanges emite cambios correctamente', () async {
    final List<LedgerModel> updates = <LedgerModel>[];

    repository
        .subscribeToLedgerChanges()
        .listen((Either<ErrorItem, LedgerModel> event) {
      event.when(
        (_) => null,
        (LedgerModel m) => updates.add(m),
      );
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));

    final Either<ErrorItem, LedgerModel> result =
        await repository.addIncome(income);
    expect(result.isRight, true);

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(updates.length, greaterThanOrEqualTo(1));
  });
}

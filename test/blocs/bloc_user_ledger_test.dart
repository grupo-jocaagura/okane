import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okane/blocs/bloc_error_item.dart';
import 'package:okane/blocs/bloc_user_ledger.dart';

import '../mocks/mocks.dart';

void main() {
  late BlocUserLedger bloc;
  late BlocError errorBloc;

  late MockAddIncomeUseCase addIncome;
  late MockAddExpenseUseCase addExpense;
  late MockGetLedgerUseCase getLedger;
  late MockListenLedgerUseCase listenLedger;
  late MockCanSpendUseCase canSpend;
  late MockGetBalanceUseCase getBalance;

  const LedgerModel fakeLedger = LedgerModel(
    nameOfLedger: 'test',
    incomeLedger: <FinancialMovementModel>[],
    expenseLedger: <FinancialMovementModel>[],
  );

  final FinancialMovementModel movement = defaultMovement;
  setUpAll(() {
    registerFallbackValue(defaultMovement);
    registerFallbackValue(defaultOkaneLedger);
  });

  setUp(() {
    registerFallbackValue(movement);
    errorBloc = BlocError();

    addIncome = MockAddIncomeUseCase();
    addExpense = MockAddExpenseUseCase();
    getLedger = MockGetLedgerUseCase();
    listenLedger = MockListenLedgerUseCase();
    canSpend = MockCanSpendUseCase();
    getBalance = MockGetBalanceUseCase();

    bloc = BlocUserLedger(
      addIncome: addIncome,
      addExpense: addExpense,
      getLedger: getLedger,
      listenLedger: listenLedger,
      canSpend: canSpend,
      getBalance: getBalance,
      blocError: errorBloc,
    );
  });

  test('initialize actualiza el estado correctamente', () async {
    when(() => getLedger.execute())
        .thenAnswer((_) async => Right<ErrorItem, LedgerModel>(fakeLedger));
    when(() => listenLedger.execute()).thenAnswer(
      (_) => const Stream<Either<ErrorItem, LedgerModel>>.empty(),
    );

    await bloc.initialize();

    expect(bloc.userLedger.nameOfLedger, 'test');
  });

  test('initialize reporta errores correctamente', () async {
    const ErrorItem error =
        ErrorItem(title: 'fail', description: 'network', code: 'ERR');
    when(() => getLedger.execute())
        .thenAnswer((_) async => Left<ErrorItem, LedgerModel>(error));
    when(() => listenLedger.execute()).thenAnswer(
      (_) => const Stream<Either<ErrorItem, LedgerModel>>.empty(),
    );

    await bloc.initialize();

    expect(errorBloc.lastError.value, isNotNull);
    expect(errorBloc.lastError.value?.title, 'fail');
  });

  test('addIncome actualiza el estado', () async {
    when(() => addIncome.execute(any()))
        .thenAnswer((_) async => Right<ErrorItem, LedgerModel>(fakeLedger));

    final Either<ErrorItem, LedgerModel> result =
        await bloc.addIncome(movement);

    expect(result.isRight, true);
    expect(bloc.userLedger.nameOfLedger, 'test');
  });

  test('addExpense captura error y lo reporta', () async {
    const ErrorItem error =
        ErrorItem(title: 'fail', description: 'logic', code: 'FAIL');
    when(() => addExpense.execute(any()))
        .thenAnswer((_) async => Left<ErrorItem, LedgerModel>(error));

    final Either<ErrorItem, LedgerModel> result =
        await bloc.addExpense(movement);

    expect(result.isLeft, true);
    expect(errorBloc.lastError.value?.code, 'FAIL');
  });

  test('canISpendIt retorna true', () {
    when(() => canSpend.execute(any(), any())).thenReturn(true);
    final bool result = bloc.canISpendIt(100);
    expect(result, true);
  });

  test('balance retorna el valor entregado por getBalance', () {
    when(() => getBalance.execute(any())).thenReturn(1200);
    final int result = bloc.balance;
    expect(result, 1200);
  });

  tearDown(() {
    bloc.dispose();
    errorBloc.dispose();
  });
}

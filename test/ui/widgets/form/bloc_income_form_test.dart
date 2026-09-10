import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okane/blocs/bloc_user_ledger.dart';
import 'package:okane/ui/utils/okane_formatter.dart';
import 'package:okane/ui/widgets/forms/bloc_income_form.dart';

class MockBlocUserLedger extends Mock implements BlocUserLedger {}

void main() {
  late MockBlocUserLedger ledger;
  late BlocIncomeForm bloc;

  FinancialMovementModel movement({
    required String id,
    required int amount,
    required String category,
  }) {
    final DateTime date = DateTime(2026, 8, 19);

    return FinancialMovementModel(
      id: id,
      amount: amount,
      category: category,
      concept: category,
      createdAt: date,
      date: date,
    );
  }

  late LedgerModel categorizedLedger;

  setUpAll(() {
    registerFallbackValue(defaultMovement);
  });

  setUp(() {
    ledger = MockBlocUserLedger();

    categorizedLedger = LedgerModel(
      nameOfLedger: 'test',
      incomeLedger: <FinancialMovementModel>[
        movement(id: 'income-1', amount: 2000000, category: 'Salario'),
        movement(id: 'income-2', amount: 500000, category: 'Freelance'),
      ],
      expenseLedger: <FinancialMovementModel>[
        movement(id: 'expense-1', amount: 1200000, category: 'Arriendo'),
        movement(id: 'expense-2', amount: 300000, category: 'Mercado'),
      ],
    );

    when(() => ledger.userLedger).thenReturn(categorizedLedger);

    bloc = BlocIncomeForm(ledger);
  });

  tearDown(() {
    bloc.dispose();
  });

  group('initial state', () {
    test('starts with empty amount', () {
      expect(bloc.amount.value, isEmpty);
      expect(bloc.amount.errorText, isNull);
    });

    test('starts with empty category', () {
      expect(bloc.category.value, isEmpty);
      expect(bloc.category.errorText, isNull);
      expect(bloc.category.suggestions, isEmpty);
    });

    test('starts invalid', () {
      expect(bloc.isValid, isFalse);
    });

    test('prettyAmount represents empty amount as zero', () {
      expect(bloc.prettyAmount(), OkaneFormatter.moneyFormatter(0));
    });
  });

  group('amount', () {
    test('accepts positive digits', () {
      bloc.onAmountChangedAttempt('128500');

      expect(bloc.amount.value, '128500');
      expect(bloc.amount.errorText, isNull);
    });

    test('removes currency symbol and separators', () {
      bloc.onAmountChangedAttempt(r'$ 128.500');

      expect(bloc.amount.value, '128500');
      expect(bloc.amount.errorText, isNull);
    });

    test('removes non numeric characters', () {
      bloc.onAmountChangedAttempt('COP 128 500');

      expect(bloc.amount.value, '128500');
      expect(bloc.amount.errorText, isNull);
    });

    test('empty value is invalid', () {
      bloc.onAmountChangedAttempt('');

      expect(bloc.amount.value, isEmpty);
      expect(bloc.amount.errorText, isNotNull);
    });

    test('input without digits is invalid', () {
      bloc.onAmountChangedAttempt(r'$ abc');

      expect(bloc.amount.value, isEmpty);
      expect(bloc.amount.errorText, isNotNull);
    });

    test('zero is invalid', () {
      bloc.onAmountChangedAttempt('0');

      expect(bloc.amount.value, '0');
      expect(bloc.amount.errorText, isNotNull);
    });

    test('prettyAmount represents current canonical amount', () {
      bloc.onAmountChangedAttempt('128500');

      expect(bloc.prettyAmount(), OkaneFormatter.moneyFormatter(128500));
    });
  });

  group('category', () {
    test('trims category', () {
      bloc.onCategoryChangedAttempt('  Salario  ');

      expect(bloc.category.value, 'Salario');
      expect(bloc.category.errorText, isNull);
    });

    test('empty category is invalid', () {
      bloc.onCategoryChangedAttempt('   ');

      expect(bloc.category.value, isEmpty);
      expect(bloc.category.errorText, isNotNull);
    });

    test('suggests matching income categories', () {
      bloc.updateBaseCategories();

      bloc.onCategoryChangedAttempt('free');

      expect(bloc.category.suggestions, <String>['Freelance']);
    });

    test('uses expense categories when isIncome is false', () {
      final BlocIncomeForm expenseBloc = BlocIncomeForm(
        ledger,
        isIncome: false,
      );
      addTearDown(expenseBloc.dispose);

      expenseBloc.updateBaseCategories();
      expenseBloc.onCategoryChangedAttempt('arr');

      expect(expenseBloc.category.suggestions, <String>['Arriendo']);
    });
  });

  group('validation', () {
    test('is valid with positive amount and category', () {
      bloc.onAmountChangedAttempt('128500');
      bloc.onCategoryChangedAttempt('Salario');

      expect(bloc.isValid, isTrue);
    });

    test('remains invalid without category', () {
      bloc.onAmountChangedAttempt('128500');

      expect(bloc.isValid, isFalse);
    });

    test('remains invalid without valid amount', () {
      bloc.onAmountChangedAttempt('0');
      bloc.onCategoryChangedAttempt('Salario');

      expect(bloc.isValid, isFalse);
    });
  });

  group('submit', () {
    test('returns NotValidForm when form is invalid', () async {
      final Either<ErrorItem, LedgerModel> result = await bloc.submit();

      expect(result.isLeft, isTrue);

      result.when((ErrorItem error) {
        expect(error.code, 'NotValidForm');
      }, (_) => fail('Expected Left'));

      verifyNever(() => ledger.addIncome(any()));
      verifyNever(() => ledger.addExpense(any()));
    });

    test('submits income using canonical integer amount', () async {
      when(() => ledger.addIncome(any())).thenAnswer(
        (_) async => Right<ErrorItem, LedgerModel>(categorizedLedger),
      );

      bloc.onAmountChangedAttempt(r'$ 128.500');
      bloc.onCategoryChangedAttempt('Salario');

      final Either<ErrorItem, LedgerModel> result = await bloc.submit();

      expect(result.isRight, isTrue);

      final FinancialMovementModel captured =
          verify(() => ledger.addIncome(captureAny())).captured.single
              as FinancialMovementModel;

      expect(captured.amount, 128500);
      expect(captured.category, 'Salario');
      expect(captured.concept, 'Salario');

      verifyNever(() => ledger.addExpense(any()));
    });

    test('submits expense through addExpense', () async {
      final BlocIncomeForm expenseBloc = BlocIncomeForm(
        ledger,
        isIncome: false,
      );
      addTearDown(expenseBloc.dispose);

      when(() => ledger.addExpense(any())).thenAnswer(
        (_) async => Right<ErrorItem, LedgerModel>(categorizedLedger),
      );

      expenseBloc.onAmountChangedAttempt('85000');
      expenseBloc.onCategoryChangedAttempt('Mercado');

      final Either<ErrorItem, LedgerModel> result = await expenseBloc.submit();

      expect(result.isRight, isTrue);

      final FinancialMovementModel captured =
          verify(() => ledger.addExpense(captureAny())).captured.single
              as FinancialMovementModel;

      expect(captured.amount, 85000);
      expect(captured.category, 'Mercado');

      verifyNever(() => ledger.addIncome(any()));
    });
  });
  group('amount editing', () {
    test('starts with amount editing disabled', () {
      expect(bloc.isAmountEditing, isFalse);
    });

    test('startAmountEditing enables amount editing', () {
      bloc.startAmountEditing();

      expect(bloc.isAmountEditing, isTrue);
    });

    test('stopAmountEditing disables amount editing', () {
      bloc.startAmountEditing();

      bloc.stopAmountEditing();

      expect(bloc.isAmountEditing, isFalse);
    });

    test('appendAmountDigit appends digits to empty amount', () {
      bloc.appendAmountDigit(1);
      bloc.appendAmountDigit(2);
      bloc.appendAmountDigit(8);

      expect(bloc.amount.value, '128');
      expect(bloc.amount.errorText, isNull);
    });

    test('appendAmountDigit keeps a single leading zero', () {
      bloc.appendAmountDigit(0);
      bloc.appendAmountDigit(0);

      expect(bloc.amount.value, '0');
    });

    test('appendAmountDigit replaces leading zero with non-zero digit', () {
      bloc.appendAmountDigit(0);
      bloc.appendAmountDigit(5);

      expect(bloc.amount.value, '5');
      expect(bloc.amount.errorText, isNull);
    });

    test('appendAmountDigit rejects values below zero', () {
      expect(() => bloc.appendAmountDigit(-1), throwsArgumentError);
    });

    test('appendAmountDigit rejects values greater than nine', () {
      expect(() => bloc.appendAmountDigit(10), throwsArgumentError);
    });

    test('removeLastAmountDigit removes last digit', () {
      bloc.onAmountChangedAttempt('128');

      bloc.removeLastAmountDigit();

      expect(bloc.amount.value, '12');
    });

    test('removeLastAmountDigit empties a single digit amount', () {
      bloc.onAmountChangedAttempt('1');

      bloc.removeLastAmountDigit();

      expect(bloc.amount.value, isEmpty);
      expect(bloc.amount.errorText, isNotNull);
    });

    test('removeLastAmountDigit is safe when amount is already empty', () {
      bloc.removeLastAmountDigit();

      expect(bloc.amount.value, isEmpty);
      expect(bloc.amount.errorText, isNotNull);
    });

    test('confirmAmountEditing closes editing when amount is valid', () {
      bloc.startAmountEditing();
      bloc.onAmountChangedAttempt('128500');

      bloc.confirmAmountEditing();

      expect(bloc.isAmountEditing, isFalse);
      expect(bloc.amount.value, '128500');
    });

    test('confirmAmountEditing keeps editing when amount is empty', () {
      bloc.startAmountEditing();

      bloc.confirmAmountEditing();

      expect(bloc.isAmountEditing, isTrue);
      expect(bloc.amount.errorText, isNotNull);
    });

    test('confirmAmountEditing keeps editing when amount is zero', () {
      bloc.startAmountEditing();
      bloc.onAmountChangedAttempt('0');

      bloc.confirmAmountEditing();

      expect(bloc.isAmountEditing, isTrue);
      expect(bloc.amount.errorText, isNotNull);
    });

    test('prettyAmount reacts to digits entered through virtual keyboard', () {
      bloc.appendAmountDigit(1);
      bloc.appendAmountDigit(2);
      bloc.appendAmountDigit(8);
      bloc.appendAmountDigit(5);
      bloc.appendAmountDigit(0);
      bloc.appendAmountDigit(0);

      expect(bloc.prettyAmount(), r'$ 128.500,00');
    });

    test('backspace updates prettyAmount consistently', () {
      bloc.onAmountChangedAttempt('128500');

      bloc.removeLastAmountDigit();

      expect(bloc.amount.value, '12850');
      expect(bloc.prettyAmount(), r'$ 12.850,00');
    });
  });
}

import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../domain/usecases/add_expense_usecase.dart';
import '../domain/usecases/add_income_use_case.dart';
import '../domain/usecases/can_spend_usecase.dart';
import '../domain/usecases/get_balance_usecase.dart';
import '../domain/usecases/get_ledger_usecase.dart';
import '../domain/usecases/listen_ledger_usecase.dart';
import '../ui/utils/okane_formatter.dart';
import 'bloc_error_item.dart';

const LedgerModel defaultOkaneLedger = LedgerModel(
  nameOfLedger: 'defaultOkane',
  incomeLedger: <FinancialMovementModel>[],
  expenseLedger: <FinancialMovementModel>[],
);

/// `BlocUserLedger` expone el estado del `LedgerModel` del usuario y orquesta los casos de uso.
///
/// Este BLoC no contiene lógica de negocio; se limita a coordinar las acciones del usuario,
/// gestionar el estado reactivo y exponer errores de operación.
class BlocUserLedger extends BlocModule {
  /// Crea una instancia del Bloc con todos sus casos de uso.
  BlocUserLedger({
    required AddIncomeUseCase addIncome,
    required AddExpenseUseCase addExpense,
    required GetLedgerUseCase getLedger,
    required ListenLedgerUseCase listenLedger,
    required CanSpendUseCase canSpend,
    required GetBalanceUseCase getBalance,
    required BlocError blocError,
  }) : _addIncome = addIncome,
       _addExpense = addExpense,
       _getLedger = getLedger,
       _listenLedger = listenLedger,
       _canSpend = canSpend,
       _blocError = blocError,
       _getBalance = getBalance;
  final BlocGeneral<LedgerModel> _userLedger = BlocGeneral<LedgerModel>(
    defaultOkaneLedger,
  );
  static const String name = 'blocUserLedger';
  final AddIncomeUseCase _addIncome;
  final AddExpenseUseCase _addExpense;
  final GetLedgerUseCase _getLedger;
  final ListenLedgerUseCase _listenLedger;
  final CanSpendUseCase _canSpend;
  final GetBalanceUseCase _getBalance;
  final BlocError _blocError;

  Stream<LedgerModel> get ledgerModelStream => _userLedger.stream;
  LedgerModel get userLedger => _userLedger.value;

  /// Inicializa el ledger con los datos remotos y comienza a escuchar cambios.
  Future<void> initialize() async {
    final Either<ErrorItem, LedgerModel> result = await _getLedger.execute();
    result.when(
      (ErrorItem error) => _blocError.report(error),
      (LedgerModel ledger) => _userLedger.value = ledger,
    );

    _listenLedger.execute().listen((Either<ErrorItem, LedgerModel> event) {
      event.when(
        (ErrorItem error) =>
            _blocError.report(error), // manejar error si es necesario
        (LedgerModel remoteLedger) => _userLedger.value = remoteLedger,
      );
    });
  }

  /// Agrega un ingreso al ledger del usuario y sincroniza con el backend.
  Future<Either<ErrorItem, LedgerModel>> addIncome(
    FinancialMovementModel movement,
  ) async {
    final Either<ErrorItem, LedgerModel> result = await _addIncome.execute(
      movement,
    );
    result.when(
      (ErrorItem error) {
        _blocError.report(error);
      },
      (LedgerModel ledger) {
        _userLedger.value = ledger;
      },
    );
    return result;
  }

  /// Agrega un egreso si hay saldo suficiente y actualiza el ledger.
  Future<Either<ErrorItem, LedgerModel>> addExpense(
    FinancialMovementModel movement,
  ) async {
    final Either<ErrorItem, LedgerModel> result = await _addExpense.execute(
      movement,
    );
    result.when(
      (ErrorItem error) => _blocError.report(error),
      (LedgerModel ledger) => _userLedger.value = ledger,
    );
    return result;
  }

  /// Retorna `true` si el usuario puede gastar el monto indicado.
  bool canISpendIt(int amount) {
    return _canSpend.execute(_userLedger.value, amount);
  }

  /// Balance total del usuario.
  int get balance => _getBalance.execute(_userLedger.value);

  int get incomes => MoneyUtils.totalAmount(_userLedger.value.incomeLedger);
  int get expenses => MoneyUtils.totalAmount(_userLedger.value.expenseLedger);

  String get incomesBalance =>
      OkaneFormatter.moneyFormatter(incomes.toDouble());
  String get totalBalance => OkaneFormatter.moneyFormatter(balance.toDouble());
  String get expensesBalance =>
      OkaneFormatter.moneyFormatter(expenses.toDouble());

  /// Representación en texto del estado del ledger.
  @override
  String toString() {
    return '''
✔ Ingresos: ${MoneyUtils.totalAmount(_userLedger.value.incomeLedger)}
💸 Gastos: ${MoneyUtils.totalAmount(_userLedger.value.expenseLedger)}
📒 Balance: $balance
''';
  }

  /// Libera los recursos del Bloc.
  @override
  void dispose() {
    _userLedger.dispose();
  }
}

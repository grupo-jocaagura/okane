import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../../blocs/bloc_user_ledger.dart';
import '../../../domain/models/field_state.dart';
import '../../utils/okane_formatter.dart';
import '../../utils/utils_ledger_categories.dart';

/// Form BLoC sólo para la UI (no lógica de negocio).
class BlocIncomeForm extends BlocModule {
  BlocIncomeForm(this._ledger, {this.isIncome = true});

  final BlocUserLedger _ledger;

  final bool isIncome;
  final BlocGeneral<bool> _amountEditing = BlocGeneral<bool>(false);

  // Estados controlados por la UI
  final BlocGeneral<FieldState> _amount = BlocGeneral<FieldState>(
    const FieldState(''),
  );
  final BlocGeneral<FieldState> _category = BlocGeneral<FieldState>(
    const FieldState(''),
  );

  List<String> _baseCategories = <String>[];

  void updateBaseCategories() {
    _baseCategories.clear();
    _baseCategories = isIncome
        ? UtilsLedgerCategory.uniqueIncomeCategories(
            _ledger.userLedger,
            categoryOf: (FinancialMovementModel m) => m.category,
          )
        : UtilsLedgerCategory.uniqueExpenseCategories(
            _ledger.userLedger,
            categoryOf: (FinancialMovementModel m) => m.category,
          );
  }

  // Streams para la vista
  Stream<FieldState> get amountStream => _amount.stream;
  Stream<FieldState> get categoryStream => _category.stream;
  Stream<bool> get amountEditingStream => _amountEditing.stream;

  bool get isAmountEditing => _amountEditing.value;
  FieldState get amount => _amount.value;
  FieldState get category => _category.value;

  void onAmountChangedAttempt(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final String clean = digits;
    final String? error =
        (clean.isEmpty || int.tryParse(clean) == null || int.parse(clean) <= 0)
        ? 'Ingresa un monto válido mayor que 0'
        : null;
    _amount.value = FieldState(clean, errorText: error);
  }

  void startAmountEditing() {
    _amountEditing.value = true;
  }

  void stopAmountEditing() {
    _amountEditing.value = false;
  }

  void appendAmountDigit(int digit) {
    if (digit < 0 || digit > 9) {
      throw ArgumentError.value(
        digit,
        'digit',
        'Amount digit must be between 0 and 9',
      );
    }

    final String current = amount.value;

    final String candidate;

    if (current.isEmpty) {
      candidate = '$digit';
    } else if (current == '0') {
      candidate = digit == 0 ? '0' : '$digit';
    } else {
      candidate = '$current$digit';
    }

    onAmountChangedAttempt(candidate);
  }

  void removeLastAmountDigit() {
    final String current = amount.value;

    if (current.isEmpty || current.length == 1) {
      onAmountChangedAttempt('');
      return;
    }

    onAmountChangedAttempt(current.substring(0, current.length - 1));
  }

  void confirmAmountEditing() {
    onAmountChangedAttempt(amount.value);

    if (isAmountValid) {
      stopAmountEditing();
    }
  }

  void onCategoryChangedAttempt(String raw) {
    final String q = raw.trim();
    final List<String> filtered = q.isEmpty
        ? const <String>[]
        : _baseCategories
              .where((String e) => e.toLowerCase().contains(q.toLowerCase()))
              .toList();
    final String? error = q.isEmpty
        ? 'Selecciona o escribe una categoría'
        : null;
    _category.value = FieldState(q, errorText: error, suggestions: filtered);
  }

  // Atajo para formatear el monto en UI (opcional)
  String prettyAmount() {
    final String v = amount.value.isEmpty ? '0' : amount.value;
    final double d = double.parse(v);
    return OkaneFormatter.moneyFormatter(d);
  }

  bool get isAmountValid => amount.errorText == null && amount.value.isNotEmpty;

  bool get isValid =>
      isAmountValid && category.errorText == null && category.value.isNotEmpty;

  Future<Either<ErrorItem, LedgerModel>> submit() async {
    onAmountChangedAttempt(amount.value);
    onCategoryChangedAttempt(category.value);
    if (!isValid) {
      return const Left<ErrorItem, LedgerModel>(
        ErrorItem(
          title: 'Formulario inválido',
          code: 'NotValidForm',
          description: 'Formulario inválido',
        ),
      );
    }

    final int amountInt = int.parse(amount.value);

    final FinancialMovementModel movement = FinancialMovementModel(
      amount: amountInt,
      category: category.value,
      createdAt: DateTime.now(),
      concept: category.value,
      id: '',
      date: DateTime.now(),
    );

    final Either<ErrorItem, LedgerModel> r = isIncome
        ? await _ledger.addIncome(movement)
        : await _ledger.addExpense(movement);
    return r;
  }

  @override
  void dispose() {
    _amount.dispose();
    _category.dispose();
    _amountEditing.dispose();
  }
}

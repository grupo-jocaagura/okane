// ui/blocs/bloc_income_form.dart
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../../blocs/bloc_user_ledger.dart';
import '../../../domain/models/field_state.dart';
import '../../utils/okane_formatter.dart';
import '../../utils/utils_ledger_categories.dart';

/// Form BLoC sólo para la UI (no lógica de negocio).
class BlocIncomeForm extends BlocModule {
  BlocIncomeForm(this._ledger);

  final BlocUserLedger _ledger;

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
    _baseCategories = UtilsLedgerCategory.uniqueIncomeCategories(
      _ledger.userLedger,
      categoryOf: (FinancialMovementModel m) => m.category,
    );
  }

  // Streams para la vista
  Stream<FieldState> get amountStream => _amount.stream;
  Stream<FieldState> get categoryStream => _category.stream;

  FieldState get amount => _amount.value;
  FieldState get category => _category.value;

  // Intentos desde la UI
  void onAmountChangedAttempt(String raw) {
    // Dejamos solo dígitos
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final String clean = digits; // unidades enteras (sin centavos)
    final String? error =
        (clean.isEmpty || int.tryParse(clean) == null || int.parse(clean) <= 0)
        ? 'Ingresa un monto válido mayor que 0'
        : null;
    _amount.value = FieldState(clean, errorText: error);
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

  bool get isValid =>
      (amount.errorText == null && amount.value.isNotEmpty) &&
      (category.errorText == null && category.value.isNotEmpty);

  Future<Either<ErrorItem, LedgerModel>> submit() async {
    onAmountChangedAttempt(amount.value);
    onCategoryChangedAttempt(category.value);
    if (!isValid) {
      return Left<ErrorItem, LedgerModel>(
        const ErrorItem(
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
      concept: 'Prueba',
      id: '',
      date: DateTime.now(),
    );

    final Either<ErrorItem, LedgerModel> r = await _ledger.addIncome(movement);
    return r;
  }

  @override
  void dispose() {
    _amount.dispose();
    _category.dispose();
  }
}

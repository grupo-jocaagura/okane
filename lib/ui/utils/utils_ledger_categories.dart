import 'dart:collection';

import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Resultado agrupado de categorías.
class LedgerCategories {
  const LedgerCategories({
    required this.incomeCategories,
    required this.expenseCategories,
    required this.allCategories,
  });

  final List<String> incomeCategories;
  final List<String> expenseCategories;
  final List<String> allCategories;
}

/// Utilitarios para extraer categorías únicas desde un LedgerModel.
///
/// - Unicidad **case-insensitive**, preservando el **primer** casing encontrado.
/// - Se ignoran categorías vacías (tras `trim()`).
class UtilsLedgerCategory {
  const UtilsLedgerCategory();

  /// Categorías únicas de ingresos.
  static List<String> uniqueIncomeCategories(
    LedgerModel ledger, {
    required String Function(FinancialMovementModel) categoryOf,
  }) {
    return _uniqueFrom(ledger.incomeLedger, categoryOf);
  }

  /// Categorías únicas de egresos.
  static List<String> uniqueExpenseCategories(
    LedgerModel ledger, {
    required String Function(FinancialMovementModel) categoryOf,
  }) {
    return _uniqueFrom(ledger.expenseLedger, categoryOf);
  }

  /// Categorías únicas combinadas (ingresos primero, luego egresos).
  static List<String> uniqueAllCategories(
    LedgerModel ledger, {
    required String Function(FinancialMovementModel) categoryOf,
  }) {
    final List<String> income = _uniqueFrom(ledger.incomeLedger, categoryOf);
    return _mergeUnique(income, _uniqueFrom(ledger.expenseLedger, categoryOf));
  }

  /// Devuelve las tres listas en un solo objeto.
  static LedgerCategories getCategories(
    LedgerModel ledger, {
    required String Function(FinancialMovementModel) categoryOf,
  }) {
    final List<String> incomes = uniqueIncomeCategories(
      ledger,
      categoryOf: categoryOf,
    );
    final List<String> expenses = uniqueExpenseCategories(
      ledger,
      categoryOf: categoryOf,
    );
    final List<String> all = _mergeUnique(incomes, expenses);
    return LedgerCategories(
      incomeCategories: incomes,
      expenseCategories: expenses,
      allCategories: all,
    );
  }

  // --------- Helpers internos ---------

  static List<String> _uniqueFrom(
    List<FinancialMovementModel> list,
    String Function(FinancialMovementModel) categoryOf,
  ) {
    // LinkedHashMap para preservar orden de inserción.
    final LinkedHashMap<String, String> seen = LinkedHashMap<String, String>();
    for (final FinancialMovementModel m in list) {
      final String raw = categoryOf(m).trim();
      if (raw.isEmpty) {
        continue;
      }
      final String key = raw.toLowerCase();
      seen.putIfAbsent(key, () => raw);
    }
    return seen.values.toList();
    // Ejemplo: ["Salario", "Venta", "Freelance"]
  }

  static List<String> _mergeUnique(List<String> a, List<String> b) {
    final LinkedHashMap<String, String> seen = LinkedHashMap<String, String>();
    void addAll(List<String> src) {
      for (final String raw in src) {
        final String key = raw.toLowerCase();
        seen.putIfAbsent(key, () => raw);
      }
    }

    addAll(a);
    addAll(b);
    return seen.values.toList();
  }
}

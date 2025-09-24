import 'package:flutter/material.dart';

const String kIconPath = 'assets/imagotipo.png';
const String kMonthIncomeLabel = 'Ingresos mes';
const String kMonthExpenseLabel = 'Gastos mes';
const String kIncomes = 'Ingresos';
const String kExpenses = 'Gastos';
const String kMovements = 'Movimientos';
const String kAddIncome = 'Registra un ingreso';
const String kAddExpense = 'Registra un gasto';
const String kIncomeCategory = r'Categoría del ingreso';
const String kExpenseCategory = r'Categoría del gasto';
const String kAmount = r'$ Monto';
const String kIncomePlaceholder = 'Ej. 120000';
const String kCategoryPlaceholder = 'Ej. Salario, Venta...';
const String kCancelButtonLabel = 'Cancelar';
const String kSaveButtonLabel = 'Guardar';
const String kSaveIncomeSuccessMessage = 'Ingreso registrado';
const String kSaveExpenseSuccessMessage = 'Gasto registrado';

const double kDefaultHeightSeparator = 16.0;
const double kSmallHeightSeparator = 6.0;
const SizedBox defaultSeparatorHeightWidget = SizedBox(
  height: kDefaultHeightSeparator,
);
const SizedBox smallSeparatorHeightWidget = SizedBox(
  height: kSmallHeightSeparator,
);
const EdgeInsets kInnerViewPadding = EdgeInsets.symmetric(horizontal: 16.0);
const double kInitialTopMargin = 79.0;

const Map<int, String> kMonths = <int, String>{
  0: 'enero',
  1: 'febrero',
  2: 'marzo',
  3: 'abril',
  4: 'mayo',
  5: 'junio',
  6: 'julio',
  7: 'agosto',
  8: 'septiembre',
  9: 'octubre',
  10: 'noviembre',
  11: 'diciembre',
};

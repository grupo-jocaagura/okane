import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../../config.dart';
import '../ui_constants.dart';
import '../utils/okane_formatter.dart';
import '../widgets/bars_chart_widget.dart';
import '../widgets/legend_widget.dart';
import '../widgets/okane_page_builder.dart';
import '../widgets/pie_chart_widget.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  static const String name = 'report';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
  );

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final BlocGeneral<ModelGraph> _barsBloc = BlocGeneral<ModelGraph>(
    defaultModelGraph(),
  );

  @override
  void initState() {
    super.initState();
    final BlocUserLedger ledgerModel = appManager
        .requireModuleByKey<BlocUserLedger>(BlocUserLedger.name);
    final ModelGraph bars = _buildMonthlyExpensesGraph(ledgerModel.userLedger);
    _barsBloc.value = bars;
  }

  @override
  void dispose() {
    _barsBloc.dispose();
    super.dispose();
  }

  Map<String, double> _sumExpensesByCategory(LedgerModel ledger) {
    final Map<String, double> out = <String, double>{};
    for (final FinancialMovementModel m in ledger.expenseLedger) {
      final String cat = m.category;
      final double v = out[cat] ?? 0.0;
      out[cat] = v + m.amount.toDouble();
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final BlocUserLedger ledgerBloc = appManager
        .requireModuleByKey<BlocUserLedger>(BlocUserLedger.name);
    return OkanePageBuilder(
      page: StreamBuilder<LedgerModel>(
        stream: ledgerBloc.ledgerModelStream,
        initialData: ledgerBloc.userLedger,
        builder: (BuildContext context, AsyncSnapshot<LedgerModel> ledgerSnap) {
          final LedgerModel? ledger = ledgerSnap.data;
          if (ledger == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final Map<String, double> byCategory = _sumExpensesByCategory(ledger);
          final double totalExpenses = byCategory.values.fold(
            0.0,
            (double a, double b) => a + b,
          );
          final TextTheme theme = Theme.of(context).textTheme;
          return StreamBuilder<ModelGraph>(
            stream: _barsBloc.stream,
            initialData: _barsBloc.value,
            builder:
                (BuildContext context, AsyncSnapshot<ModelGraph> barsSnap) {
                  final ModelGraph? bars = barsSnap.data;
                  if (bars == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints c) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // --- Ponqué por categoría ---
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Por categoría',
                                textAlign: TextAlign.center,
                                style: theme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            AspectRatio(
                              aspectRatio: 1.1,
                              child: Card(
                                elevation: 2,
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: PieChartWidget(
                                    totals: byCategory,
                                    colors: categoryColors,
                                    centerLabel: 'Gasto total',
                                    centerValue: OkaneFormatter.moneyFormatter(
                                      totalExpenses,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- Barras por mes (egreso) ---
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Por fecha',
                                textAlign: TextAlign.center,
                                style: theme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            AspectRatio(
                              aspectRatio: 1.7,
                              child: Card(
                                elevation: 2,
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    8,
                                  ),
                                  child: BarsChartWidget(graph: bars),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            LegendWidget(
                              colors: categoryColors,
                              totals: byCategory,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
          );
        },
      ),
    );
  }

  ModelGraph _buildMonthlyExpensesGraph(LedgerModel ledger) {
    // Total de egresos por mes; etiquetas minúsculas "ene", "feb", ...
    final List<String> short = <String>[
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final List<Map<String, Object?>> rows = <Map<String, Object?>>[];

    for (int m = 1; m <= 12; m++) {
      double sum = 0.0;
      for (final FinancialMovementModel e in ledger.expenseLedger) {
        if (e.date.year == 2024 && e.date.month == m) {
          sum += e.amount.toDouble();
        }
      }
      rows.add(<String, Object?>{'label': short[m - 1], 'value': sum});
    }

    // Creamos ModelGraph (ejes se calculan automáticamente).
    final ModelGraph g = ModelGraph.fromTable(
      rows,
      xLabelKey: 'label',
      yValueKey: 'value',
      title: 'Gasto mensual 2024',
      subtitle: 'Totales por mes (COP)',
      description: 'Fuente: ledger demo',
      xTitle: 'Mes',
      yTitle: 'COP',
    );
    return g;
  }
}

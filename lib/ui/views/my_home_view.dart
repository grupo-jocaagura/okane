import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../../config.dart';

class MyHomeView extends StatelessWidget {
  const MyHomeView({super.key});

  static String name = 'my-home-view';

  @override
  Widget build(BuildContext context) {
    final BlocUserLedger blocUserLedger =
        appManager.blocCore.getBlocModule<BlocUserLedger>(BlocUserLedger.name);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Okane'),
      ),
      body: StreamBuilder<LedgerModel>(
        stream: blocUserLedger.ledgerModelStream,
        builder: (_, __) {
          final LedgerModel ledger = blocUserLedger.userLedger;
          final int ingresos = MoneyUtils.totalAmount(ledger.incomeLedger);
          final int egresos = MoneyUtils.totalAmount(ledger.expenseLedger);
          final int balance = ingresos - egresos;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('✔ Ingresos: $ingresos'),
              Text('💸 Egresos: $egresos'),
              Text('📒 Balance: $balance'),
              const Text(
                'You have pushed the button this many times:',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () {
                      blocUserLedger.addIncome(
                        FinancialMovementModel(
                          id: DateTime.now().toIso8601String(),
                          amount: 1000,
                          concept: 'Ingreso aleatorio',
                          category: 'Salary',
                          date: DateTime.now(),
                          createdAt: DateTime.now(),
                          detailedDescription: 'Ingreso generado',
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Ingreso'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      blocUserLedger.addExpense(
                        FinancialMovementModel(
                          id: DateTime.now().toIso8601String(),
                          amount: 500,
                          concept: 'Gasto aleatorio',
                          category: 'Food',
                          date: DateTime.now(),
                          createdAt: DateTime.now(),
                          detailedDescription: 'Egreso generado',
                        ),
                      );
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text('Agregar Gasto'),
                  ),
                ],
              ),
            ],
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

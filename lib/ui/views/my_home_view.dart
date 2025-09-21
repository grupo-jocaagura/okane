import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../../config.dart';
import '../ui_constants.dart';
import '../widgets/balance_widget.dart';
import '../widgets/circle_avatar_widget.dart';
import '../widgets/okane_page_builder.dart';
import '../widgets/projector_widget.dart';
import '../widgets/square_button_widget.dart';
import 'expenses_view.dart';
import 'income_view.dart';

class MyHomeView extends StatelessWidget {
  const MyHomeView({super.key});

  static const String name = 'my-home-view';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
  );

  @override
  Widget build(BuildContext context) {
    final BlocUserLedger blocUserLedger = appManager
        .requireModuleByKey<BlocUserLedger>(BlocUserLedger.name);

    context.appManager.mainMenu.addMainMenuOption(
      onPressed: () {
        debugPrint('Test me');
      },
      label: 'Inicializando',
      iconData: Icons.check,
    );

    return OkanePageBuilder(
      page: StreamBuilder<LedgerModel>(
        stream: blocUserLedger.ledgerModelStream,
        builder: (_, __) {
          return ProjectorWidget(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 166.0),
                const CircleAvatarWidget(),
                const SizedBox(height: 16),
                const BalanceWidget(),
                const SizedBox(height: 65),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <SquareButtonWidget>[
                    SquareButtonWidget(
                      ontap: () => context.appManager.pageManager.push(
                        IncomeView.pageModel,
                      ),
                      quarterTurns: 1,
                      title: kIncomes,
                      subtitle: blocUserLedger.incomesBalance,
                    ),
                    SquareButtonWidget(
                      ontap: () => context.appManager.pageManager.push(
                        ExpensesView.pageModel,
                      ),
                      quarterTurns: 3,
                      title: kExpenses,
                      subtitle: blocUserLedger.expensesBalance,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <SquareButtonWidget>[
                    SquareButtonWidget(
                      quarterTurns: 4,
                      title: 'Movimientos',
                      subtitle: blocUserLedger.totalBalance,
                    ),
                    const SquareButtonWidget(
                      quarterTurns: 2,
                      title: 'Informes',
                      subtitle: 'Subhead',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

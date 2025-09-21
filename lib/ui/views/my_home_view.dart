import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../../config.dart';
import '../utils/okane_formatter.dart';
import '../widgets/balance_widget.dart';
import '../widgets/circle_avatar_widget.dart';
import '../widgets/okane_page_builder.dart';
import '../widgets/projector_widget.dart';
import '../widgets/square_button_widget.dart';

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
          final LedgerModel ledger = blocUserLedger.userLedger;
          final int ingresos = MoneyUtils.totalAmount(ledger.incomeLedger);
          final int egresos = MoneyUtils.totalAmount(ledger.expenseLedger);
          final int balance = ingresos - egresos;
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
                      quarterTurns: 1,
                      title: 'Ingresos',
                      subtitle: OkaneFormatter.moneyFormatter(
                        ingresos.toDouble(),
                      ),
                    ),
                    SquareButtonWidget(
                      quarterTurns: 3,
                      title: 'Gastos',
                      subtitle: OkaneFormatter.moneyFormatter(
                        egresos.toDouble(),
                      ),
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
                      subtitle: OkaneFormatter.moneyFormatter(
                        balance.toDouble(),
                      ),
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

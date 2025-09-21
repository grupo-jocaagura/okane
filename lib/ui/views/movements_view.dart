import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../ui_constants.dart';
import '../widgets/inner_content_widget.dart';
import '../widgets/list_of_movements_widget.dart';
import '../widgets/okane_page_builder.dart';
import '../widgets/resume_movements_widget.dart';

class MovementsView extends StatelessWidget {
  const MovementsView({super.key});
  static const String name = 'movements';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
  );

  @override
  Widget build(BuildContext context) {
    final BlocUserLedger bloc = context.appManager
        .requireModuleByKey<BlocUserLedger>(BlocUserLedger.name);

    return OkanePageBuilder(
      page: InnerContentWidget(
        topMargin: false,
        title: kMovements,
        quarterTurns: 4,
        children: <Widget>[
          ResumeMovementsWidget(
            incomes: bloc.incomesBalance,
            expenses: bloc.expensesBalance,
          ),
          defaultSeparatorHeightWidget,
          Expanded(child: ListOfMovementsWidget(ledgerModel: bloc.userLedger)),
          Container(width: 312, height: 48, color: Colors.brown),
          smallSeparatorHeightWidget,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../ui_constants.dart';
import '../widgets/forms/form_ledger_widget.dart';
import '../widgets/inner_content_widget.dart';
import '../widgets/okane_page_builder.dart';

class IncomeView extends StatelessWidget {
  const IncomeView({super.key});
  static const String name = 'income';
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
        title: kIncomes,
        quarterTurns: 1,
        subtitle: '${kMonths[DateTime.now().month]} ${bloc.incomesBalance}',
        children: const <Widget>[SizedBox(height: 100.0), FormLedgerWidget()],
      ),
    );
  }
}

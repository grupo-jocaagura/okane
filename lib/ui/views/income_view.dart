import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

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
    return const OkanePageBuilder(
      page: InnerContentWidget(
        title: kIncomes,
        quarterTurns: 1,
        subtitle: r"Marzo $ 2'000.000",
        children: <Widget>[SizedBox(height: 100.0), FormLedgerWidget()],
      ),
    );
  }
}

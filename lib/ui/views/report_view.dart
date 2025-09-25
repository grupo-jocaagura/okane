import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_user_ledger.dart';
import '../../config.dart';
import '../widgets/okane_page_builder.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  static const String name = 'report';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
  );

  @override
  Widget build(BuildContext context) {
    final BlocUserLedger blocUserLedger = appManager
        .requireModuleByKey<BlocUserLedger>(BlocUserLedger.name);
    return OkanePageBuilder(
      page: StreamBuilder<LedgerModel>(
        stream: blocUserLedger.ledgerModelStream,
        builder: (BuildContext context, AsyncSnapshot<LedgerModel> snapshot) {
          return const Placeholder();
        },
      ),
    );
  }
}

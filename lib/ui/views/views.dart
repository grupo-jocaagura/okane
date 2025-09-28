import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'expenses_view.dart';
import 'income_view.dart';
import 'movements_view.dart';
import 'my_home_view.dart';
import 'report_view.dart';
import 'splash_screen_view.dart';

const List<PageModel> views = <PageModel>[SplashScreenView.pageModel];

final NavStackModel navStackModel = NavStackModel(views);

final PageRegistry pageRegistry = PageRegistry.fromDefs(<PageDef>[
  PageDef(
    model: MyHomeView.pageModel,
    builder: (_, PageModel view) => const MyHomeView(),
  ),
  PageDef(
    model: SplashScreenView.pageModel,
    builder: (_, PageModel view) => const SplashScreenView(),
  ),

  PageDef(
    model: IncomeView.pageModel,
    builder: (_, PageModel view) => const IncomeView(),
  ),
  PageDef(
    model: ExpensesView.pageModel,
    builder: (_, PageModel view) => const ExpensesView(),
  ),
  PageDef(
    model: MovementsView.pageModel,
    builder: (_, PageModel view) => const MovementsView(),
  ),
  PageDef(
    model: ReportView.pageModel,
    builder: (_, PageModel view) => const ReportView(),
  ),
]);

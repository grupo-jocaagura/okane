import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'my_home_view.dart';
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
]);

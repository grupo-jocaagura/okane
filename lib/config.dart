import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'app/env.dart';

final JocaaguraArchetype jocaaguraArchetype = JocaaguraArchetype();

final AppManager appManager = AppManager(
  Env.build(AppEnvironment.dev),
);

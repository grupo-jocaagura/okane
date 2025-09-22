// env_config.dart
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../blocs/bloc_error_item.dart';
import '../blocs/bloc_user_ledger.dart';
import '../domain/entities/services/service_w_s_database.dart';
import '../domain/gateway/ledger_ws_gateway.dart';
import '../domain/repositories/ledger_reporitory.dart';
import '../domain/usecases/add_expense_usecase.dart';
import '../domain/usecases/add_income_use_case.dart';
import '../domain/usecases/can_spend_usecase.dart';
import '../domain/usecases/get_balance_usecase.dart';
import '../domain/usecases/get_ledger_usecase.dart';
import '../domain/usecases/listen_ledger_usecase.dart';
import '../infrastructure/gateways/ledger_ws_gateway_impl.dart';
import '../infrastructure/repositories/ledger_repository_impl.dart';
import '../infrastructure/services/fake_service_w_s_database.dart';
import '../infrastructure/services/hive_service_ws_database.dart';
import '../infrastructure/services/service_okane_theme.dart';
import '../ui/views/views.dart';

/// Entornos soportados para el armado de la app.
/// Se usa en [Env.build] para crear un [AppConfig] especializado.
enum AppEnvironment { dev, qa, prod }

/// -------------------------------
/// 1) BINDINGS por ambiente
/// -------------------------------
/// Único lugar donde decidimos *qué* implementación usar en cada ambiente.
class EnvBindings {
  const EnvBindings({required this.wsDatabase});

  /// Servicio WS-like para persistencia (simulado/real).
  final ServiceWSDatabase wsDatabase;

  /// Fábricas por ambiente.
  static EnvBindings forEnv(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
        return EnvBindings(wsDatabase: FakeServiceWSDatabase());
      case AppEnvironment.qa:
        // Si QA quiere datos reales pero en sandbox, puedes alternar aquí.
        return EnvBindings(wsDatabase: HiveServiceWSDatabase());
      case AppEnvironment.prod:
        return EnvBindings(wsDatabase: HiveServiceWSDatabase());
    }
  }
}

/// -------------------------------
/// 2) FACTORÍAS puras de wiring
/// -------------------------------

/// Gateways
class GatewayFactory {
  const GatewayFactory();

  LedgerWsGateway makeLedgerGateway(ServiceWSDatabase svc) {
    return LedgerWsGatewayImpl(svc);
  }
}

/// Repositorios
class RepositoryFactory {
  const RepositoryFactory();

  LedgerRepository makeLedgerRepository(LedgerWsGateway gw) {
    return LedgerRepositoryImpl(gw);
  }
}

/// BLoCs de dominio de Okane
class BlocFactory {
  const BlocFactory();

  /// Crea el [BlocUserLedger] cableado con sus casos de uso.
  BlocUserLedger makeLedgerBloc({
    required LedgerRepository repo,
    required BlocError blocError,
  }) {
    return BlocUserLedger(
      addIncome: AddIncomeUseCase(repo),
      addExpense: AddExpenseUseCase(repo),
      getLedger: GetLedgerUseCase(repo),
      listenLedger: ListenLedgerUseCase(repo),
      canSpend: CanSpendUseCase(),
      getBalance: GetBalanceUseCase(),
      blocError: blocError,
    );
  }

  /// Crea el bloque temático (tema M3 + overrides + escala).
  BlocTheme makeThemeBloc() {
    return BlocTheme(
      themeUsecases: ThemeUsecases.fromRepo(
        RepositoryThemeImpl(
          gateway: GatewayThemeImpl(themeService: const ServiceOkaneTheme()),
        ),
      ),
    );
  }
}

/// -------------------------------
/// 3) BUILDER de AppConfig
/// -------------------------------

/// Construye un [AppConfig] completamente cableado según el ambiente.
///
/// # Ejemplo (MD)
/// ```dart
/// final AppConfig config = Env.build(AppEnvironment.dev);
/// runApp(OkaneApp(appManager: AppManager(config), registry: pageRegistry));
/// ```
class Env {
  static AppConfig build(AppEnvironment env) {
    final EnvBindings bindings = EnvBindings.forEnv(env);
    const GatewayFactory gateways = GatewayFactory();
    const RepositoryFactory repositories = RepositoryFactory();
    const BlocFactory blocs = BlocFactory();

    final LedgerWsGateway ledgerGw = gateways.makeLedgerGateway(
      bindings.wsDatabase,
    );
    final LedgerRepository ledgerRepo = repositories.makeLedgerRepository(
      ledgerGw,
    );

    final BlocError blocError = BlocError();
    final BlocUserLedger blocUserLedger = blocs.makeLedgerBloc(
      repo: ledgerRepo,
      blocError: blocError,
    );

    return AppConfig(
      blocTheme: blocs.makeThemeBloc(),

      blocUserNotifications: BlocUserNotifications(),
      blocLoading: BlocLoading(),
      blocMainMenuDrawer: BlocMainMenuDrawer(),
      blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
      blocResponsive: BlocResponsive(),
      blocOnboarding: BlocOnboarding(),

      blocModuleList: <String, BlocModule>{
        BlocUserLedger.name: blocUserLedger,
        BlocError.name: blocError,
      },

      pageManager: PageManager(initial: navStackModel),
    );
  }
}

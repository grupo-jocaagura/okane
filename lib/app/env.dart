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

/// Define los entornos disponibles para la aplicación.
///
/// Se utiliza en la clase [Env] para construir un [AppConfig] personalizado
/// de acuerdo al entorno activo (`dev`, `qa`, `prod`).
enum AppEnvironment { dev, qa, prod }

final BlocError _blocError = BlocError();
final ServiceWSDatabase _serviceWSDatabase = FakeServiceWSDatabase();
final ServiceWSDatabase _serviceProdWSDatabase = HiveServiceWSDatabase();
final LedgerWsGateway _ledgerWsGateway = LedgerWsGatewayImpl(
  _serviceWSDatabase,
);
final LedgerWsGateway _ledgerProdWsGateway = LedgerWsGatewayImpl(
  _serviceProdWSDatabase,
);
final LedgerRepository _ledgerRepository = LedgerRepositoryImpl(
  _ledgerWsGateway,
);
final LedgerRepository _ledgerProdRepository = LedgerRepositoryImpl(
  _ledgerProdWsGateway,
);
final BlocUserLedger _blocUserLedger = BlocUserLedger(
  addIncome: AddIncomeUseCase(_ledgerRepository),
  addExpense: AddExpenseUseCase(_ledgerRepository),
  getLedger: GetLedgerUseCase(_ledgerRepository),
  listenLedger: ListenLedgerUseCase(_ledgerRepository),
  canSpend: CanSpendUseCase(),
  getBalance: GetBalanceUseCase(),
  blocError: _blocError,
);
final BlocUserLedger _blocProdUserLedger = BlocUserLedger(
  addIncome: AddIncomeUseCase(_ledgerProdRepository),
  addExpense: AddExpenseUseCase(_ledgerProdRepository),
  getLedger: GetLedgerUseCase(_ledgerProdRepository),
  listenLedger: ListenLedgerUseCase(_ledgerProdRepository),
  canSpend: CanSpendUseCase(),
  getBalance: GetBalanceUseCase(),
  blocError: _blocError,
);

/// Generador de configuraciones para ambientes.
///
/// La clase [Env] permite construir una instancia de [AppConfig]
/// según el entorno seleccionado ([AppEnvironment]).
/// Cada configuración puede incluir diferentes servicios, gateways,
/// repositorios y BLoCs personalizados.
///
/// Esta clase facilita:
/// - Alternar entre entornos con una sola línea.
/// - Reutilizar lógica de construcción.
/// - Aislar configuraciones específicas.
///
/// ## Ejemplo de uso:
///
/// ```dart
/// final AppConfig config = Env.build(AppEnvironment.dev);
/// runApp(MyApp(config: config));
/// ```
class Env {
  /// Construye la configuración correspondiente al entorno indicado.
  ///
  /// Esta función inicializa manualmente los servicios requeridos para el entorno.
  /// Actualmente todos los entornos apuntan a [devAppConfig], pero pueden
  /// extenderse fácilmente para producción o pruebas.
  static AppConfig build(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
        return devAppConfig;

      case AppEnvironment.qa:
        return devAppConfig; // reemplazar por configuración QA

      case AppEnvironment.prod:
        return prodAppConfig; // reemplazar por configuración real
    }
  }
}

/// Configuración base para el entorno de desarrollo.
///
/// Esta configuración utiliza `FakeServiceWSDatabase` como backend simulado
/// y contiene wiring completo de dependencias con sus respectivos BLoCs.
///
/// Puede modificarse rápidamente para pruebas, demo, o entorno local.
///
/// ## Componentes incluidos:
/// - BLoCs de UI (tema, navegación, responsive, etc.).
/// - [BlocUserLedger] conectado a `LedgerRepositoryImpl`.
/// - [BlocError] como manejador de errores global.
///
/// ## ¿Por qué usar esta estructura?
/// - Permite testear sin servicios reales.
/// - Mantiene la arquitectura desacoplada.
/// - Es fácilmente escalable para otros entornos.
final AppConfig devAppConfig = AppConfig(
  blocTheme: BlocTheme(
    themeUsecases: ThemeUsecases.fromRepo(
      RepositoryThemeImpl(
        gateway: GatewayThemeImpl(themeService: const ServiceOkaneTheme()),
      ),
    ),
  ),
  blocUserNotifications: BlocUserNotifications(),
  blocLoading: BlocLoading(),
  blocMainMenuDrawer: BlocMainMenuDrawer(),
  blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
  blocResponsive: BlocResponsive(),
  blocOnboarding: BlocOnboarding(),
  blocModuleList: <String, BlocModule>{
    BlocUserLedger.name: _blocUserLedger,
    BlocError.name: _blocError,
  },
  pageManager: PageManager(initial: navStackModel),
);

final AppConfig prodAppConfig = AppConfig(
  blocTheme: BlocTheme(
    themeUsecases: ThemeUsecases.fromRepo(
      RepositoryThemeImpl(
        gateway: GatewayThemeImpl(themeService: const ServiceOkaneTheme()),
      ),
    ),
  ),
  blocUserNotifications: BlocUserNotifications(),
  blocLoading: BlocLoading(),
  blocMainMenuDrawer: BlocMainMenuDrawer(),
  blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
  blocResponsive: BlocResponsive(),
  blocOnboarding: BlocOnboarding(),
  blocModuleList: <String, BlocModule>{
    BlocUserLedger.name: _blocProdUserLedger,
    BlocError.name: _blocError,
  },
  pageManager: PageManager(initial: navStackModel),
);

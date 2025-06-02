import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
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
import '../ui/views/my_home_view.dart';
import '../ui/views/splash_screen_view.dart';

/// Define los entornos disponibles para la aplicación.
///
/// Se utiliza en la clase [Env] para construir un [AppConfig] personalizado
/// de acuerdo al entorno activo (`dev`, `qa`, `prod`).
enum AppEnvironment { dev, qa, prod }

final BlocTheme _blocTheme = BlocTheme(
  const ProviderTheme(
    ServiceTheme(),
  ),
);
final BlocUserNotifications _blocUserNotifications = BlocUserNotifications();
final BlocLoading _blocLoading = BlocLoading();
final BlocMainMenuDrawer _blocMainMenuDrawer = BlocMainMenuDrawer();
final BlocSecondaryMenuDrawer _blocSecondaryMenuDrawer =
    BlocSecondaryMenuDrawer();
final BlocResponsive _blocResponsive = BlocResponsive();
final BlocOnboarding _blocOnboarding = BlocOnboarding(
  <Future<void> Function()>[
    // reemplazar por las funciones iniciales de configuración

    () async {
      await Future<void>.delayed(
        const Duration(seconds: 5),
      );
      _blocResponsive.showAppbar = false;
    },
    () async {
      _blocNavigator.addPagesForDynamicLinksDirectory(<String, Widget>{
        MyHomeView.name: const MyHomeView(),
      });
    },
    () async {
      _blocNavigator.setHomePageAndUpdate(
        const MyHomeView(),
      );
    },
  ],
);
final BlocNavigator _blocNavigator = BlocNavigator(
  PageManager(),
  SplashScreenView(
    blocOnboarding: _blocOnboarding,
  ),
);

final BlocError _blocError = BlocError();
final ServiceWSDatabase _serviceWSDatabase = FakeServiceWSDatabase();
final LedgerWsGateway _ledgerWsGateway =
    LedgerWsGatewayImpl(_serviceWSDatabase);
final LedgerRepository _ledgerRepository =
    LedgerRepositoryImpl(_ledgerWsGateway);
final BlocUserLedger _blocUserLedger = BlocUserLedger(
  addIncome: AddIncomeUseCase(_ledgerRepository),
  addExpense: AddExpenseUseCase(_ledgerRepository),
  getLedger: GetLedgerUseCase(_ledgerRepository),
  listenLedger: ListenLedgerUseCase(_ledgerRepository),
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
    _blocError.lastError.addFunctionToProcessTValueOnStream('notify_to_user',
        (ErrorItem? errorItem) {
      if (errorItem?.errorLevel == ErrorLevelEnum.systemInfo) {
        debugPrint('$ErrorItem');
      }
      if (errorItem?.errorLevel != ErrorLevelEnum.systemInfo &&
          errorItem != null) {
        _blocUserNotifications
            .showToast('${errorItem.title}:\n${errorItem.description}');
      }
    });

    switch (env) {
      case AppEnvironment.dev:
        return devAppConfig;

      case AppEnvironment.qa:
        return devAppConfig; // reemplazar por configuración QA

      case AppEnvironment.prod:
        return devAppConfig; // reemplazar por configuración real
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
  blocTheme: _blocTheme,
  blocUserNotifications: _blocUserNotifications,
  blocLoading: _blocLoading,
  blocMainMenuDrawer: _blocMainMenuDrawer,
  blocSecondaryMenuDrawer: _blocSecondaryMenuDrawer,
  blocResponsive: _blocResponsive,
  blocOnboarding: _blocOnboarding,
  blocNavigator: _blocNavigator,
  blocModuleList: <String, BlocModule>{
    BlocUserLedger.name: _blocUserLedger,
    BlocError.name: _blocError,
  },
);

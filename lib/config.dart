import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'ui/views/my_home_view.dart';

final JocaaguraArchetype jocaaguraArchetype = JocaaguraArchetype();
final BlocTheme blocTheme = BlocTheme(
  const ProviderTheme(
    ServiceTheme(),
  ),
);
final BlocUserNotifications blocUserNotifications = BlocUserNotifications();
final BlocLoading blocLoading = BlocLoading();
final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer =
    BlocSecondaryMenuDrawer();
final BlocResponsive blocResponsive = BlocResponsive();
final BlocOnboarding blocOnboarding = BlocOnboarding(
  <Future<void> Function()>[
    // reemplazar por las funciones iniciales de configuración
    () async {
      blocNavigator.addPagesForDynamicLinksDirectory(<String, Widget>{
        MyHomeView.name: const MyHomeView(),
      });
    },
    () async {
      blocNavigator.setHomePageAndUpdate(
        const MyHomeView(),
      );
    },
  ],
);
final BlocNavigator blocNavigator = BlocNavigator(
  PageManager(),
  OnBoardingPage(
    blocOnboarding: blocOnboarding,
  ),
);

final AppManager appManager = AppManager(
  AppConfig(
    blocTheme: blocTheme,
    blocUserNotifications: blocUserNotifications,
    blocLoading: blocLoading,
    blocMainMenuDrawer: blocMainMenuDrawer,
    blocSecondaryMenuDrawer: blocSecondaryMenuDrawer,
    blocResponsive: blocResponsive,
    blocOnboarding: blocOnboarding,
    blocNavigator: blocNavigator,
    blocModuleList: <String, BlocModule>{},
  ),
);

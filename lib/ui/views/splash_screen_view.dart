import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:text_responsive/text_responsive.dart';

import '../../main.dart';
import '../widgets/okane_page_builder.dart';
import 'my_home_view.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});
  static const String name = 'splash';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
  );

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  late BlocOnboarding _onboarding;
  StreamSubscription<OnboardingState>? _sub;
  bool _configured = false;
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onboarding = context.appManager.onboarding;

    if (_configured) {
      return;
    }
    _configured = true;

    final List<OnboardingStep> steps = <OnboardingStep>[
      OnboardingStep(
        title: 'Probando',
        autoAdvanceAfter: const Duration(seconds: 5),
        description:
            'Probando funcion del onboarding, simulando carga del canvas',
        onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      ),
    ];

    // 1) Configurar y arrancar una sola vez.
    if (_onboarding.state.status == OnboardingStatus.idle) {
      _onboarding.configure(steps);
      _onboarding.start();
    }

    // 2) Navegar una sola vez cuando termine (completed/skipped).
    _sub = _onboarding.stateStream.listen((OnboardingState s) {
      if (_navigated) {
        return;
      }
      if (s.status == OnboardingStatus.completed ||
          s.status == OnboardingStatus.skipped) {
        _navigated = true;
        navigate();
      }
    });
  }

  void navigate() {
    if (context.mounted) {
      context.appManager.pageManager.debugLogStack(' BEFORE NAV');
      context.appManager.replaceTopModel(MyHomeView.pageModel);
      context.appManager.pageManager.debugLogStack('  AFTER NAV');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OkanePageBuilder(
      showWavyHeader: false,
      page: Column(
        children: <Widget>[
          const SizedBox(height: 280.0),
          SizedBox(
            width: 196.92,
            height: 45.0,
            child: Image.asset('assets/logo.png'),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: StreamBuilder<OnboardingState>(
              stream: _onboarding.stateStream,
              initialData: _onboarding.state,
              builder: (_, AsyncSnapshot<OnboardingState> snap) {
                final OnboardingState s = snap.data ?? _onboarding.state;

                final OnboardingStep? step = _onboarding.currentStep;
                final String line = switch (s.status) {
                  OnboardingStatus.idle => 'Preparando inicio…',
                  OnboardingStatus.running => _formatRunningLine(s, step),
                  OnboardingStatus.completed => '¡Listo!',
                  OnboardingStatus.skipped => 'Omitido',
                };

                return Column(
                  children: <Widget>[
                    Center(
                      child: InlineTextWidget(
                        line,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (s.error != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        s.error?.title ?? 'Error',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextButton(
                            onPressed: _onboarding.retryOnEnter,
                            child: const Text('Reintentar'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _onboarding.skip,
                            child: const Text('Omitir'),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  /// Formats "i/N · Title" while running.
  static String _formatRunningLine(OnboardingState s, OnboardingStep? step) {
    final int current = (s.stepIndex >= 0 ? s.stepIndex : 0) + 1;
    final int total = (s.totalSteps > 0 ? s.totalSteps : 1);
    final String title = (step?.title.isNotEmpty ?? false)
        ? step!.title
        : 'Cargando…';
    return '$current/$total · $title';
  }
}

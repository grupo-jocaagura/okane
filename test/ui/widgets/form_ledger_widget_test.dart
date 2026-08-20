import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:okane/app/env.dart';
import 'package:okane/ui/widgets/amount_magnifier_widget.dart';
import 'package:okane/ui/widgets/forms/form_ledger_widget.dart';
import 'package:okane/ui/widgets/virtual_amount_keyboard_widget.dart';

void main() {
  late AppManager appManager;

  setUp(() {
    appManager = AppManager(OkaneEnv.build(AppEnvironment.dev));
  });

  tearDown(() {
    if (!appManager.isDisposed) {
      appManager.dispose();
    }
  });

  Widget buildSubject({bool isIncome = true}) {
    return AppManagerProvider(
      appManager: appManager,
      child: MaterialApp(
        home: Scaffold(
          body: Center(child: FormLedgerWidget(isIncome: isIncome)),
        ),
      ),
    );
  }

  Future<void> openAmountEditor(
    WidgetTester tester, {
    bool isIncome = true,
  }) async {
    await tester.pumpWidget(buildSubject(isIncome: isIncome));

    await tester.tap(find.bySemanticsLabel('Monto'));

    await tester.pumpAndSettle();
  }

  Future<void> enterDigits(WidgetTester tester, List<int> digits) async {
    for (final int digit in digits) {
      await tester.tap(find.text('$digit'));

      await tester.pump();
    }
  }

  testWidgets('opens controlled amount editor when amount is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.semantics.byLabel('Cantidad formateada'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Monto'));

    await tester.pumpAndSettle();

    expect(find.byType(AmountMagnifierWidget), findsOneWidget);

    expect(find.byType(VirtualAmountKeyboardWidget), findsOneWidget);

    expect(find.semantics.byLabel('Cantidad formateada'), findsOne);
  });

  testWidgets('formats amount live from virtual keyboard digits', (
    WidgetTester tester,
  ) async {
    await openAmountEditor(tester);

    await enterDigits(tester, <int>[1, 2, 8, 5, 0, 0]);

    expect(find.text(r'$ 128.500,00'), findsOneWidget);
  });

  testWidgets('backspace updates formatted amount', (
    WidgetTester tester,
  ) async {
    await openAmountEditor(tester);

    await enterDigits(tester, <int>[1, 2, 8, 5, 0, 0]);

    await tester.tap(find.bySemanticsLabel('Borrar último dígito'));

    await tester.pump();

    expect(find.text(r'$ 12.850,00'), findsOneWidget);
  });

  testWidgets('confirm closes editor when amount is valid', (
    WidgetTester tester,
  ) async {
    await openAmountEditor(tester);

    await enterDigits(tester, <int>[1, 2, 8, 5, 0, 0]);

    expect(find.semantics.byLabel('Cantidad formateada'), findsOne);

    await tester.tap(find.bySemanticsLabel('Confirmar cantidad'));

    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('Cantidad formateada'), findsNothing);
  });

  testWidgets('confirm keeps editor open when amount is invalid', (
    WidgetTester tester,
  ) async {
    await openAmountEditor(tester);

    await tester.tap(find.bySemanticsLabel('Confirmar cantidad'));

    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('Cantidad formateada'), findsOne);
  });

  testWidgets('closing editor preserves entered amount', (
    WidgetTester tester,
  ) async {
    await openAmountEditor(tester);

    await enterDigits(tester, <int>[1, 2, 8]);

    await tester.tap(find.byTooltip('Cerrar teclado de cantidad'));

    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('Cantidad formateada'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Monto'));

    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('Cantidad formateada'), findsOne);

    expect(find.text(r'$ 128,00'), findsOneWidget);
  });

  testWidgets('expense form uses the same controlled amount flow', (
    WidgetTester tester,
  ) async {
    await openAmountEditor(tester, isIncome: false);

    await enterDigits(tester, <int>[8, 5, 0, 0, 0]);

    expect(find.byType(VirtualAmountKeyboardWidget), findsOneWidget);

    expect(find.text(r'$ 85.000,00'), findsOneWidget);
  });
}

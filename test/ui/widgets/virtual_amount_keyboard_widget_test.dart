import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okane/ui/widgets/virtual_amount_keyboard_widget.dart';

void main() {
  Widget buildSubject({
    required ValueChanged<int> onDigitPressed,
    required VoidCallback onBackspacePressed,
    required VoidCallback onConfirmPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 240,
            height: 280,
            child: VirtualAmountKeyboardWidget(
              onDigitPressed: onDigitPressed,
              onBackspacePressed: onBackspacePressed,
              onConfirmPressed: onConfirmPressed,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders digits from zero to nine', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        onDigitPressed: (_) {},
        onBackspacePressed: () {},
        onConfirmPressed: () {},
      ),
    );

    for (int digit = 0; digit <= 9; digit++) {
      expect(find.text('$digit'), findsOneWidget);
    }
  });

  testWidgets('emits pressed digits', (WidgetTester tester) async {
    final List<int> digits = <int>[];

    await tester.pumpWidget(
      buildSubject(
        onDigitPressed: digits.add,
        onBackspacePressed: () {},
        onConfirmPressed: () {},
      ),
    );

    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('8'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('0'));

    expect(digits, <int>[1, 2, 8, 5, 0, 0]);
  });

  testWidgets('invokes backspace callback', (WidgetTester tester) async {
    int calls = 0;

    await tester.pumpWidget(
      buildSubject(
        onDigitPressed: (_) {},
        onBackspacePressed: () {
          calls++;
        },
        onConfirmPressed: () {},
      ),
    );

    await tester.tap(find.bySemanticsLabel('Borrar último dígito'));

    expect(calls, 1);
  });

  testWidgets('invokes confirm callback', (WidgetTester tester) async {
    int calls = 0;

    await tester.pumpWidget(
      buildSubject(
        onDigitPressed: (_) {},
        onBackspacePressed: () {},
        onConfirmPressed: () {
          calls++;
        },
      ),
    );

    await tester.tap(find.bySemanticsLabel('Confirmar cantidad'));

    expect(calls, 1);
  });

  testWidgets('exposes accessible actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        onDigitPressed: (_) {},
        onBackspacePressed: () {},
        onConfirmPressed: () {},
      ),
    );

    expect(find.bySemanticsLabel('Borrar último dígito'), findsOneWidget);

    expect(find.bySemanticsLabel('Confirmar cantidad'), findsOneWidget);
  });
}

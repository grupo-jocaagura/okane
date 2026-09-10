import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okane/ui/widgets/virtual_key_widget.dart';

void main() {
  Widget buildSubject({
    required String label,
    required VoidCallback onTap,
    String? semanticLabel,
    IconData? icon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 80,
          height: 64,
          child: VirtualKeyWidget(
            label: label,
            onTap: onTap,
            semanticLabel: semanticLabel,
            icon: icon,
          ),
        ),
      ),
    );
  }

  testWidgets('renders label', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(label: '8', onTap: () {}));

    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('invokes callback on tap', (WidgetTester tester) async {
    int taps = 0;

    await tester.pumpWidget(
      buildSubject(
        label: '8',
        onTap: () {
          taps++;
        },
      ),
    );

    await tester.tap(find.text('8'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('renders icon instead of label when icon is provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        label: 'Borrar',
        semanticLabel: 'Borrar último dígito',
        icon: Icons.backspace_outlined,
        onTap: () {},
      ),
    );

    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

    expect(find.text('Borrar'), findsNothing);
  });

  testWidgets('exposes custom semantics label', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        label: '⌫',
        semanticLabel: 'Borrar último dígito',
        onTap: () {},
      ),
    );

    expect(find.bySemanticsLabel('Borrar último dígito'), findsOneWidget);
  });

  testWidgets('custom semantics replaces visual label semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        label: '⌫',
        semanticLabel: 'Borrar último dígito',
        onTap: () {},
      ),
    );

    expect(find.bySemanticsLabel('Borrar último dígito'), findsOneWidget);

    expect(find.bySemanticsLabel('⌫'), findsNothing);
  });
}

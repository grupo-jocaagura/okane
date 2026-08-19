import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okane/ui/widgets/amount_magnifier_widget.dart';

void main() {
  Widget buildSubject({
    required String formattedAmount,
    required bool visible,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: AmountMagnifierWidget(
              formattedAmount: formattedAmount,
              visible: visible,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders formatted amount', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(formattedAmount: r'$ 128.500,00', visible: true),
    );

    expect(find.text(r'$ 128.500,00'), findsOneWidget);
  });

  testWidgets('is fully visible when visible is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(formattedAmount: r'$ 128.500,00', visible: true),
    );

    final AnimatedOpacity opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );

    final AnimatedScale scale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );

    expect(opacity.opacity, 1);
    expect(scale.scale, 1);
  });

  testWidgets('is visually hidden when visible is false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(formattedAmount: r'$ 128.500,00', visible: false),
    );

    final AnimatedOpacity opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );

    final AnimatedScale scale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );

    expect(opacity.opacity, 0);
    expect(scale.scale, lessThan(1));
  });

  testWidgets('exposes formatted amount through semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(formattedAmount: r'$ 128.500,00', visible: true),
    );

    expect(find.bySemanticsLabel('Cantidad formateada'), findsOneWidget);

    final Semantics semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label == 'Cantidad formateada',
      ),
    );

    expect(semantics.properties.value, r'$ 128.500,00');
  });

  testWidgets('removes semantics when hidden', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(formattedAmount: r'$ 128.500,00', visible: false),
    );

    expect(find.bySemanticsLabel('Cantidad formateada'), findsNothing);
  });

  testWidgets('supports dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        formattedAmount: r'$ 128.500,00',
        visible: true,
        theme: ThemeData.dark(),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(r'$ 128.500,00'), findsOneWidget);
  });
}

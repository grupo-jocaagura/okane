import 'package:flutter/material.dart';

import '../utils/okane_formatter.dart';

class LegendWidget extends StatelessWidget {
  const LegendWidget({required this.colors, required this.totals, super.key});
  final Map<String, Color> colors;
  final Map<String, double> totals;

  @override
  Widget build(BuildContext context) {
    final List<String> cats = totals.keys.toList()..sort();
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final String c in cats)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[c] ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('$c (${OkaneFormatter.moneyFormatter(totals[c] ?? 0)})'),
            ],
          ),
      ],
    );
  }
}

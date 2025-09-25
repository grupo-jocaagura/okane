import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'painters/bars_painter.dart';

class BarsChartWidget extends StatelessWidget {
  const BarsChartWidget({super.key, required this.graph});
  final ModelGraph graph;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BarsPainter(graph: graph),
      child: const SizedBox.expand(),
    );
  }
}

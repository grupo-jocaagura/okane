import 'package:flutter/material.dart';

import '../ui_constants.dart';

class IconWidget extends StatelessWidget {
  const IconWidget({this.quarterTurns = 0, this.width = 50.0, super.key});

  final double width;
  final int quarterTurns;
  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: SizedBox(
        width: width,
        height: width,
        child: Image.asset(kIconPath),
      ),
    );
  }
}

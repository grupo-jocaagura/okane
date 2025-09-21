import 'package:flutter/material.dart';

import 'wavy_header_widget.dart';

class OkaneScaffoldWidget extends StatelessWidget {
  const OkaneScaffoldWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Widget contentWidget = child ?? const SizedBox.shrink();
    return Scaffold(
      body: Stack(children: <Widget>[const WavyHeaderWidget(), contentWidget]),
    );
  }
}

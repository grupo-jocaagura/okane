import 'package:flutter/material.dart';

import '../ui_constants.dart';
import 'icon_widget.dart';
import 'title_widget.dart';

class InnerContentWidget extends StatelessWidget {
  const InnerContentWidget({
    super.key,
    this.title = '',
    this.subtitle = '',
    this.quarterTurns = 0,
    this.children = const <Widget>[],
    this.topMargin = true,
  });

  final String title;
  final String subtitle;
  final int quarterTurns;
  final List<Widget> children;
  final bool topMargin;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kInnerViewPadding,
      child: Column(
        children: <Widget>[
          const SizedBox(height: kInitialTopMargin),
          Row(
            children: <Widget>[
              TitleWidget(title: title),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 115),
          Row(
            children: <Widget>[
              const Expanded(child: SizedBox()),
              IconWidget(quarterTurns: quarterTurns),
            ],
          ),
          if (topMargin) const SizedBox(height: 40.0),
          Row(
            children: <Widget>[
              const Expanded(child: SizedBox()),
              TitleWidget(title: subtitle),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

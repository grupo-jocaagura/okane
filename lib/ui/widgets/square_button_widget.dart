import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

import 'icon_widget.dart';

class SquareButtonWidget extends StatelessWidget {
  const SquareButtonWidget({
    required this.title,
    required this.subtitle,
    super.key,
    this.sideLength = 180,
    this.quarterTurns = 0,
    this.ontap,
  });
  final double sideLength;

  final String title;
  final String subtitle;
  final int quarterTurns;
  final GestureTapCallback? ontap;

  @override
  Widget build(BuildContext context) {
    final double iconSideLength = sideLength * (5 / 18);

    return InkWell(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.all(sideLength * 0.08),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(sideLength * 0.1),
        ),
        width: sideLength,
        height: sideLength,

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 30.0),
                  InlineTextWidget(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  InlineTextWidget(
                    subtitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            IconWidget(width: iconSideLength, quarterTurns: quarterTurns),
          ],
        ),
      ),
    );
  }
}

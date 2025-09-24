import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:text_responsive/text_responsive.dart';

import '../ui_constants.dart';
import '../utils/okane_formatter.dart';

class MovementWidget extends StatelessWidget {
  const MovementWidget({
    required this.movement,
    this.isIncome = true,
    super.key,
  });

  final FinancialMovementModel movement;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (!isIncome) const Expanded(child: SizedBox()),
        Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: kSmallHeightSeparator),
              width: 312,
              height: 66,
              color: Theme.of(context).colorScheme.surfaceBright,
              child: SizedBox(
                height: 66.0,
                width: 264.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(3.0),
                      width: 18.0,
                      height: 18.0,
                      decoration: BoxDecoration(
                        color: isIncome
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    SizedBox(
                      width: 80.0,
                      height: 48.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 24,
                            child: InlineTextWidget(
                              OkaneFormatter.dateFormatter(movement.createdAt),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          SizedBox(
                            height: 22,
                            child: InlineTextWidget(
                              movement.category,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120.0,
                      height: 65,
                      child: Center(
                        child: InlineTextWidget(
                          OkaneFormatter.intMoneyFormatter(movement.amount),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 2.0,
              width: 264.0,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ],
        ),
      ],
    );
  }
}

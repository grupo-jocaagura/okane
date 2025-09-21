import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

class InnerResumeMovementsWidget extends StatelessWidget {
  const InnerResumeMovementsWidget({
    required this.amount,
    required this.label,
    super.key,
  });

  final String amount;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 143.0,
      height: 48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InlineTextWidget(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          InlineTextWidget(
            amount,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

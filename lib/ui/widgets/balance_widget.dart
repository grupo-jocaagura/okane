import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

import '../utils/okane_formatter.dart';

class BalanceWidget extends StatelessWidget {
  const BalanceWidget({super.key, this.balance = 0.0});

  final double balance;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 264,
      height: 32,
      child: InlineTextWidget(
        'Balance ${OkaneFormatter.moneyFormatter(balance)}',
        textAlign: TextAlign.center,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

class BalanceWidget extends StatelessWidget {
  const BalanceWidget({super.key, this.balance = r'$ 0.00'});

  final String balance;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 264,
      height: 32,
      child: InlineTextWidget('Balance $balance}', textAlign: TextAlign.center),
    );
  }
}

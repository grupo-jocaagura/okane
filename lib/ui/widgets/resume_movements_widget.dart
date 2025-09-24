import 'package:flutter/material.dart';

import '../ui_constants.dart';
import 'inner_resume_movements_widget.dart';

class ResumeMovementsWidget extends StatelessWidget {
  const ResumeMovementsWidget({
    required this.incomes,
    required this.expenses,
    super.key,
  });

  final String incomes;
  final String expenses;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <InnerResumeMovementsWidget>[
        InnerResumeMovementsWidget(label: kMonthIncomeLabel, amount: incomes),
        InnerResumeMovementsWidget(label: kMonthExpenseLabel, amount: expenses),
      ],
    );
  }
}

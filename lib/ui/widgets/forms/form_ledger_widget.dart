import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:text_responsive/text_responsive.dart';

import '../../../blocs/bloc_user_ledger.dart';
import '../../../config.dart';
import '../../../domain/models/field_state.dart';
import '../../ui_constants.dart';
import '../title_widget.dart';
import 'bloc_income_form.dart';

class FormLedgerWidget extends StatefulWidget {
  const FormLedgerWidget({this.isIncome = true, super.key});

  final bool isIncome;

  @override
  State<FormLedgerWidget> createState() => _FormLedgerWidgetState();
}

class _FormLedgerWidgetState extends State<FormLedgerWidget> {
  late final BlocIncomeForm blocForm;

  @override
  void initState() {
    super.initState();
    final BlocUserLedger ledgerBloc = appManager
        .requireModuleByKey<BlocUserLedger>(BlocUserLedger.name);

    blocForm = BlocIncomeForm(ledgerBloc, isIncome: widget.isIncome);
    blocForm.updateBaseCategories();
  }

  @override
  void dispose() {
    blocForm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kInnerViewPadding,
      width: 312.0,
      height: 375.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Theme.of(context).colorScheme.outlineVariant,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 312,
            height: 116,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: kDefaultHeightSeparator),
                TitleWidget(title: widget.isIncome ? kAddIncome : kAddExpense),
              ],
            ),
          ),
          StreamBuilder<FieldState>(
            stream: blocForm.amountStream,
            initialData: blocForm.amount,
            builder: (_, __) {
              final FieldState s = blocForm.amount;
              return JocaaguraAutocompleteInputWidget(
                label: kAmount,
                placeholder: kIncomePlaceholder,
                value: s.value,
                errorText: s.errorText,
                textInputType: TextInputType.number,
                textInputAction: TextInputAction.next,
                icondata: Icons.attach_money,
                onChangedAttempt: blocForm.onAmountChangedAttempt,
                onSubmittedAttempt: (_) {},
              );
            },
          ),
          defaultSeparatorHeightWidget,
          StreamBuilder<FieldState>(
            stream: blocForm.categoryStream,
            initialData: blocForm.category,
            builder: (_, __) {
              final FieldState s = blocForm.category;
              return JocaaguraAutocompleteInputWidget(
                label: widget.isIncome ? kIncomeCategory : kExpenseCategory,
                placeholder: kCategoryPlaceholder,
                value: s.value,
                errorText: s.errorText,
                suggestList: s.suggestions,
                textInputAction: TextInputAction.next,
                icondata: Icons.category_outlined,
                onChangedAttempt: blocForm.onCategoryChangedAttempt,
                onSubmittedAttempt: (_) {},
              );
            },
          ),
          defaultSeparatorHeightWidget,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: context.appManager.pageManager.pop,
                child: const InlineTextWidget(kCancelButtonLabel),
              ),
              TextButton(
                onPressed: () async {
                  final Either<ErrorItem, LedgerModel> r = await blocForm
                      .submit();
                  r.when(
                    (ErrorItem e) =>
                        appManager.notifications.showToast(e.title),
                    (_) {
                      appManager.notifications.showToast(
                        widget.isIncome
                            ? kSaveIncomeSuccessMessage
                            : kSaveExpenseSuccessMessage,
                      );
                      context.appManager.pageManager.pop();
                    },
                  );
                },
                child: const InlineTextWidget(kSaveButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

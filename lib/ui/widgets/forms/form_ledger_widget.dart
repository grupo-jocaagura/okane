import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:text_responsive/text_responsive.dart';

import '../../../blocs/bloc_user_ledger.dart';
import '../../../domain/models/field_state.dart';
import '../../ui_constants.dart';
import '../amount_magnifier_widget.dart';
import '../title_widget.dart';
import '../virtual_amount_keyboard_widget.dart';
import 'bloc_income_form.dart';

class FormLedgerWidget extends StatefulWidget {
  const FormLedgerWidget({this.isIncome = true, super.key});

  final bool isIncome;

  @override
  State<FormLedgerWidget> createState() => _FormLedgerWidgetState();
}

class _FormLedgerWidgetState extends State<FormLedgerWidget> {
  late final BlocIncomeForm blocForm;

  bool _blocFormInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_blocFormInitialized) {
      return;
    }

    final BlocUserLedger ledgerBloc = context.appManager
        .requireModuleByKey<BlocUserLedger>(BlocUserLedger.name);

    blocForm = BlocIncomeForm(ledgerBloc, isIncome: widget.isIncome);

    blocForm.updateBaseCategories();

    _blocFormInitialized = true;
  }

  @override
  void dispose() {
    if (_blocFormInitialized) {
      blocForm.dispose();
    }

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
      child: Stack(
        children: <Widget>[_buildForm(context), _buildAmountEditor(context)],
      ),
    );
  }

  Widget _buildAmountEditor(BuildContext context) {
    return StreamBuilder<bool>(
      stream: blocForm.amountEditingStream,
      initialData: blocForm.isAmountEditing,
      builder: (_, __) {
        final bool editing = blocForm.isAmountEditing;

        return Positioned.fill(
          child: IgnorePointer(
            ignoring: !editing,
            child: ExcludeSemantics(
              excluding: !editing,
              child: AnimatedOpacity(
                opacity: editing ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Material(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Ingresa la cantidad',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Cerrar teclado de cantidad',
                              onPressed: blocForm.stopAmountEditing,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),

                        StreamBuilder<FieldState>(
                          stream: blocForm.amountStream,
                          initialData: blocForm.amount,
                          builder: (_, __) {
                            final FieldState state = blocForm.amount;

                            return Column(
                              children: <Widget>[
                                AmountMagnifierWidget(
                                  formattedAmount: blocForm.prettyAmount(),
                                  visible: editing,
                                ),
                                SizedBox(
                                  height: 20,
                                  child: state.errorText == null
                                      ? null
                                      : Text(
                                          state.errorText!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                              ),
                                        ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        Expanded(
                          child: VirtualAmountKeyboardWidget(
                            onDigitPressed: blocForm.appendAmountDigit,
                            onBackspacePressed: blocForm.removeLastAmountDigit,
                            onConfirmPressed: blocForm.confirmAmountEditing,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
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

            return Semantics(
              button: true,
              label: 'Monto',
              value: blocForm.prettyAmount(),
              hint: 'Toca para ingresar la cantidad',
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: blocForm.startAmountEditing,
                  child: AbsorbPointer(
                    child: JocaaguraAutocompleteInputWidget(
                      label: kAmount,
                      placeholder: kIncomePlaceholder,
                      value: s.value,
                      errorText: s.errorText,
                      textInputType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      icondata: Icons.attach_money,
                      onChangedAttempt: blocForm.onAmountChangedAttempt,
                      onSubmittedAttempt: (_) {},
                    ),
                  ),
                ),
              ),
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
                      context.appManager.notifications.showToast(e.title),
                  (_) {
                    context.appManager.notifications.showToast(
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
    );
  }
}

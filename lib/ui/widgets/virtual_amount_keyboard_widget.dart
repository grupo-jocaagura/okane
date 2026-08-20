import 'package:flutter/material.dart';

import 'virtual_key_widget.dart';

class VirtualAmountKeyboardWidget extends StatelessWidget {
  const VirtualAmountKeyboardWidget({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onConfirmPressed,
    super.key,
  });

  final ValueChanged<int> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onConfirmPressed;

  static const double _spacing = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _DigitRow(
            digits: const <int>[1, 2, 3],
            onDigitPressed: onDigitPressed,
          ),
        ),
        const SizedBox(height: _spacing),
        Expanded(
          child: _DigitRow(
            digits: const <int>[4, 5, 6],
            onDigitPressed: onDigitPressed,
          ),
        ),
        const SizedBox(height: _spacing),
        Expanded(
          child: _DigitRow(
            digits: const <int>[7, 8, 9],
            onDigitPressed: onDigitPressed,
          ),
        ),
        const SizedBox(height: _spacing),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: VirtualKeyWidget(
                  label: 'Borrar',
                  semanticLabel: 'Borrar último dígito',
                  icon: Icons.backspace_outlined,
                  variant: VirtualKeyVariant.secondary,
                  onTap: onBackspacePressed,
                ),
              ),
              const SizedBox(width: _spacing),
              Expanded(
                child: VirtualKeyWidget(
                  label: '0',
                  onTap: () => onDigitPressed(0),
                ),
              ),
              const SizedBox(width: _spacing),
              Expanded(
                child: VirtualKeyWidget(
                  label: 'Confirmar',
                  semanticLabel: 'Confirmar cantidad',
                  icon: Icons.check_rounded,
                  variant: VirtualKeyVariant.primary,
                  onTap: onConfirmPressed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DigitRow extends StatelessWidget {
  const _DigitRow({required this.digits, required this.onDigitPressed});

  final List<int> digits;
  final ValueChanged<int> onDigitPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int index = 0; index < digits.length; index++) ...<Widget>[
          if (index > 0)
            const SizedBox(width: VirtualAmountKeyboardWidget._spacing),
          Expanded(
            child: VirtualKeyWidget(
              label: '${digits[index]}',
              onTap: () => onDigitPressed(digits[index]),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AmountMagnifierWidget extends StatelessWidget {
  const AmountMagnifierWidget({
    required this.formattedAmount,
    required this.visible,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  final String formattedAmount;
  final bool visible;
  final EdgeInsets padding;

  static const Duration _animationDuration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: _animationDuration,
        child: AnimatedScale(
          scale: visible ? 1 : 0.96,
          duration: _animationDuration,
          child: ExcludeSemantics(
            excluding: !visible,
            child: Semantics(
              container: true,
              label: 'Cantidad formateada',
              value: formattedAmount,
              child: Card(
                elevation: 4,
                color: theme.colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: padding,
                  child: ExcludeSemantics(
                    child: Text(
                      formattedAmount,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

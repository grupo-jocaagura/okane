import 'package:flutter/material.dart';

class AmountMagnifierWidget extends StatelessWidget {
  const AmountMagnifierWidget({
    required this.formattedAmount,
    required this.visible,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 12,
    ),
  });

  final String formattedAmount;
  final bool visible;
  final EdgeInsets padding;

  static const Duration _animationDuration =
  Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: colors.outlineVariant,
      ),
    );

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
              child: Material(
                color: colors.surfaceContainerHighest,
                elevation: 1,
                shape: shape,
                child: Padding(
                  padding: padding,
                  child: ExcludeSemantics(
                    child: SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formattedAmount,
                          maxLines: 1,
                          style:
                          theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
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

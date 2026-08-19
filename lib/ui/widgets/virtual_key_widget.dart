import 'package:flutter/material.dart';

class VirtualKeyWidget extends StatelessWidget {
  const VirtualKeyWidget({
    required this.label,
    required this.onTap,
    super.key,
    this.semanticLabel,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: icon != null
                ? Icon(icon)
                : Text(label, style: theme.textTheme.headlineMedium),
          ),
        ),
      ),
    );
  }
}

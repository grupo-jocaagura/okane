import 'package:flutter/material.dart';

enum VirtualKeyVariant {
  neutral,
  secondary,
  primary,
}

class VirtualKeyWidget extends StatelessWidget {
  const VirtualKeyWidget({
    required this.label,
    required this.onTap,
    super.key,
    this.semanticLabel,
    this.icon,
    this.variant = VirtualKeyVariant.neutral,
  });

  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;
  final IconData? icon;
  final VirtualKeyVariant variant;

  static const double _borderRadius = 14;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Color backgroundColor = switch (variant) {
      VirtualKeyVariant.neutral => colors.surfaceContainerHigh,
      VirtualKeyVariant.secondary => colors.secondaryContainer,
      VirtualKeyVariant.primary => colors.primary,
    };

    final Color foregroundColor = switch (variant) {
      VirtualKeyVariant.neutral => colors.onSurface,
      VirtualKeyVariant.secondary => colors.error,
      VirtualKeyVariant.primary => colors.onPrimary,
    };

    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      side: variant == VirtualKeyVariant.neutral
          ? BorderSide(
        color: colors.outlineVariant,
      )
          : BorderSide.none,
    );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: backgroundColor,
        elevation: variant == VirtualKeyVariant.primary ? 1 : 0,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Center(
            child: icon != null
                ? Icon(
              icon,
              color: foregroundColor,
              size: 24,
            )
                : Text(
              label,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

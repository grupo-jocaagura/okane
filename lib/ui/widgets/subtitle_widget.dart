import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

class SubtitleWidget extends StatelessWidget {
  const SubtitleWidget({required this.subtitle, super.key});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InlineTextWidget(
      subtitle,
      style: Theme.of(context).textTheme.titleSmall,
    );
  }
}

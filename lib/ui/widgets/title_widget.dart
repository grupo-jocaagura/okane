import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return InlineTextWidget(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

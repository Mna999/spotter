import 'package:flutter/material.dart';

class TextFormTitle extends StatelessWidget {
  const TextFormTitle({
    super.key,
    required this.text,
    required this.cs,
    required this.title,
    required this.isRequired,
  });

  final TextTheme text;
  final ColorScheme cs;
  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title),
        const Spacer(),
        Text(
          isRequired ? 'REQUIRED' : 'OPTIONAL',
          style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class SpotterTitle extends StatelessWidget {
  const SpotterTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            './lib/core/assets/images/logo.png',
            width: 36,
            height: 36,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spotter',
              style: text.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Be spot on.',
              style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

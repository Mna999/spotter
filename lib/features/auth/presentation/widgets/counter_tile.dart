import 'package:flutter/material.dart';

class CounterTile extends StatelessWidget {
  const CounterTile({
    super.key,
    required this.value,
    required this.unit,
    required this.onIncrement,
    required this.onDecrement,
    this.icon = Icons.flag_outlined,
  });

  final int value;
  final String unit;
  final IconData icon;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: cs.surfaceContainerHighest,
      foregroundColor: cs.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: cs.outline),
            const SizedBox(width: 12),
            Text('$value', style: text.headlineMedium),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                unit,
                style: text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove),
              style: buttonStyle,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add),
              style: buttonStyle,
            ),
          ],
        ),
      ),
    );
  }
}
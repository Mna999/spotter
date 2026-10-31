import 'package:flutter/material.dart';

/// Friendly empty / error state shared by every nutrition screen.
class NutritionMessageView extends StatelessWidget {
  const NutritionMessageView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.restaurant_menu,
    this.isError = false,
    this.onAction,
    this.actionLabel = 'RETRY',
  });

  final String title;
  final String message;
  final IconData icon;
  final bool isError;
  final VoidCallback? onAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final accent = isError ? cs.error : cs.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(icon, size: 30, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: text.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodySmall!.copyWith(color: accent),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

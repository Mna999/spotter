import 'package:flutter/material.dart';

/// Shows how adding a food affects the user's daily EGP budget.
class BudgetImpactCard extends StatelessWidget {
  const BudgetImpactCard({
    super.key,
    required this.budgetEgp,
    required this.currentSpentEgp,
    required this.addedCostEgp,
  });

  final double budgetEgp;
  final double currentSpentEgp;
  final double addedCostEgp;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final newTotal = currentSpentEgp + addedCostEgp;
    final over = newTotal > budgetEgp;
    final existingShare = budgetEgp <= 0
        ? 0.0
        : (currentSpentEgp / budgetEgp).clamp(0.0, 1.0);
    final addedShare = budgetEgp <= 0
        ? 0.0
        : (addedCostEgp / budgetEgp).clamp(0.0, 1.0);
    final color = over ? cs.error : cs.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'EGYPTIAN DAILY FOOD BUDGET',
                  style: text.labelSmall!.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                '+${addedCostEgp.toStringAsFixed(0)} EGP',
                style: text.labelMedium!.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 8,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: cs.surfaceContainerHighest),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: existingShare,
                          child: ColoredBox(color: cs.secondary),
                        ),
                      ),
                      Positioned(
                        left: width * existingShare,
                        top: 0,
                        bottom: 0,
                        width: width * addedShare,
                        child: ColoredBox(color: color),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'New total: ${currentSpentEgp.toStringAsFixed(0)} → '
                  '${newTotal.toStringAsFixed(0)} EGP',
                  style: text.bodySmall!.copyWith(color: cs.onSurface),
                ),
              ),
              if (over)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 13, color: cs.error),
                      const SizedBox(width: 3),
                      Text(
                        'Over budget',
                        style: text.labelSmall!.copyWith(color: cs.error),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

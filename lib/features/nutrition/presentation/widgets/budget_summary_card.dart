import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';

/// Daily budget + energy snapshot (mockups: "Daily Budget / الميزانية").
///
/// Shows the spent EGP against the daily cap and the calories still
/// remaining for the day, with a single progress bar for the budget.
class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({
    super.key,
    required this.spentEgp,
    required this.budgetEgp,
    required this.kcalRemaining,
  });

  final double spentEgp;
  final double budgetEgp;
  final double kcalRemaining;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final over = budgetEgp > 0 && spentEgp > budgetEgp;
    final progress = budgetEgp <= 0
        ? 0.0
        : (spentEgp / budgetEgp).clamp(0.0, 1.0);
    final percent = budgetEgp <= 0
        ? 0
        : ((spentEgp / budgetEgp) * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: over ? cs.error : cs.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'DAILY BUDGET / الميزانية',
                    style: text.labelSmall!.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    '$percent% Used',
                    style: text.labelSmall!.copyWith(
                      color: over ? cs.error : cs.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  DateFormatter.thousands(spentEgp),
                  style: text.headlineMedium!.copyWith(
                    color: over ? cs.error : cs.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ ${DateFormatter.thousands(budgetEgp)} EGP',
                  style: text.bodySmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '${DateFormatter.thousands(kcalRemaining)} kcal',
                  style: text.labelMedium!.copyWith(color: cs.primary),
                ),
                Text(
                  ' remaining',
                  style: text.bodySmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: cs.surfaceContainer,
                valueColor: AlwaysStoppedAnimation(
                  over ? cs.error : cs.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

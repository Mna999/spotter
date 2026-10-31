import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';

/// Plan summary card used by the meal-plan list.
class MealPlanCard extends StatelessWidget {
  const MealPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.onDelete,
  });

  final MealPlan plan;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final budget = plan.budgetEgp;
    final hasBudget = budget != null && budget > 0;
    final progress = hasBudget
        ? (plan.costEgp / budget).clamp(0.0, 1.0)
        : 0.0;
    final over = plan.isOverBudget;
    final statusColor = switch (plan.status) {
      _ when plan.status.name == 'committed' => cs.primary,
      _ when plan.status.name == 'archived' => cs.outline,
      _ => cs.secondary,
    };

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      planStatusLabel(plan.status),
                      style: text.labelSmall!.copyWith(color: statusColor),
                    ),
                  ),
                  const Spacer(),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      tooltip: 'Delete plan',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 19,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                friendlyDate(plan.date),
                style: text.titleLarge!.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                DateFormatter.weekday(plan.date),
                style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Metric(
                    icon: Icons.local_fire_department_outlined,
                    label: '${plan.totalKcal.round()} kcal',
                    color: cs.primary,
                  ),
                  _Metric(
                    icon: Icons.account_balance_wallet_outlined,
                    label: egp(plan.costEgp),
                    color: over ? cs.error : cs.secondary,
                  ),
                  if (hasBudget)
                    _Metric(
                      icon: Icons.savings_outlined,
                      label: 'Budget ${egp(budget)}',
                      color: cs.onSurfaceVariant,
                    ),
                ],
              ),
              if (hasBudget) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: over ? cs.error : cs.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  over
                      ? 'Over budget by ${egp(plan.costEgp - budget)}'
                      : '${egp(budget - plan.costEgp)} left in budget',
                  style: text.labelSmall!.copyWith(
                    color: over ? cs.error : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: text.labelSmall!.copyWith(color: color)),
        ],
      ),
    );
  }
}

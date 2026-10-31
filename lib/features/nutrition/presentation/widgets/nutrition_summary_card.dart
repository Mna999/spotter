import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/theme/app_theme.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';

/// The "calories remaining" hero card used on the nutrition dashboard and the
/// meal-plan screen. It mirrors the daily allocation / macro summary block in
/// the design reference.
class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({
    super.key,
    required this.consumed,
    this.targetKcal,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    this.budgetEgp,
    this.spentEgp,
    this.logCount,
  });

  final MacroNutrients consumed;
  final double? targetKcal;
  final double? targetProteinG;
  final double? targetCarbsG;
  final double? targetFatG;
  final double? budgetEgp;
  final double? spentEgp;
  final int? logCount;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final target = targetKcal ?? 0;
    final hasTarget = target > 0;
    final remaining = hasTarget ? target - consumed.energyKcal : 0.0;
    final progress = hasTarget
        ? (consumed.energyKcal / target).clamp(0.0, 1.0)
        : 0.0;
    final over = hasTarget && remaining < 0;
    final statusColor = over ? cs.error : context.appColors.success;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CALORIES REMAINING',
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          DateFormatter.thousands(
                            hasTarget ? remaining.abs() : consumed.energyKcal,
                          ),
                          style: text.displayLarge!.copyWith(
                            color: cs.primary,
                            fontSize: 46,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasTarget ? 'kcal / ${DateFormatter.thousands(target)}' : 'kcal',
                          style: text.bodyMedium!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(
                label: hasTarget ? (over ? 'OVER TARGET' : 'ON TRACK') : 'LOGGING',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              color: over ? cs.error : cs.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroPill(
                  label: 'PROTEIN',
                  value: consumed.proteinG,
                  target: targetProteinG,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroPill(
                  label: 'CARBS',
                  value: consumed.carbohydrateG,
                  target: targetCarbsG,
                  color: context.appColors.carbs,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroPill(
                  label: 'FATS',
                  value: consumed.fatG,
                  target: targetFatG,
                  color: context.appColors.warning,
                ),
              ),
            ],
          ),
          if (budgetEgp != null && budgetEgp! > 0) ...[
            const SizedBox(height: 14),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: cs.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'DAILY BUDGET',
                  style: text.labelSmall!.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(spentEgp ?? 0).toStringAsFixed(0)} / ${budgetEgp!.toStringAsFixed(0)} EGP',
                  style: text.labelMedium!.copyWith(color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ((spentEgp ?? 0) / budgetEgp!).clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: cs.surfaceContainerHighest,
                color: (spentEgp ?? 0) > budgetEgp! ? cs.error : cs.secondary,
              ),
            ),
          ],
          if (logCount != null) ...[
            const SizedBox(height: 10),
            Text(
              '$logCount ${logCount == 1 ? 'item' : 'items'} logged today',
              style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: text.labelSmall!.copyWith(color: color, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
    this.target,
  });

  final String label;
  final double value;
  final double? target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final targetText = target != null && target! > 0
        ? ' / ${target!.round()}'
        : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${value.round()}g',
                  style: text.labelLarge!.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: targetText,
                  style: text.bodySmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

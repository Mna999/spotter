import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';

/// One eaten food in the daily log.
class MealLogCard extends StatelessWidget {
  const MealLogCard({
    super.key,
    required this.log,
    required this.onEdit,
    required this.onDelete,
    this.food,
  });

  final MealLog log;
  final FoodItem? food;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final item = food;
    final kcal = item == null ? log.computedKcal : kcalFor(item, log.grams);
    final macros = item == null ? null : macrosFor(item, log.grams);
    final name = item?.nameEn ?? 'Food item';
    final arabic = item?.nameAr;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Icon(
                    mealTypeIcon(log.mealType),
                    color: cs.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mealTypeLabel(log.mealType).toUpperCase()} · '
                        '${DateFormatter.clock(log.loggedAt)}',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleLarge!.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (arabic != null && arabic.trim().isNotEmpty)
                        Text(
                          arabic,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${kcal.round()}',
                      style: text.titleLarge!.copyWith(color: cs.primary),
                    ),
                    Text(
                      'kcal',
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InfoPill(
                  icon: Icons.straighten,
                  label: portionSummary(log.portion, log.servingsCount),
                ),
                if (macros != null) ...[
                  _InfoPill(
                    icon: Icons.fitness_center,
                    label: 'P ${macros.proteinG.round()}g',
                  ),
                  _InfoPill(
                    icon: Icons.grain,
                    label: 'C ${macros.carbohydrateG.round()}g',
                  ),
                  _InfoPill(
                    icon: Icons.water_drop_outlined,
                    label: 'F ${macros.fatG.round()}g',
                  ),
                ],
              ],
            ),
            if (log.note != null && log.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                log.note!,
                style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('EDIT'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('DELETE'),
                  style: TextButton.styleFrom(foregroundColor: cs.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

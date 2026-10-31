import 'package:flutter/material.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';

/// One planned food inside a meal plan.
class MealEntryCard extends StatelessWidget {
  const MealEntryCard({
    super.key,
    required this.entry,
    required this.onLog,
    this.food,
    this.isLogging = false,
  });

  final MealEntry entry;
  final FoodItem? food;
  final VoidCallback onLog;
  final bool isLogging;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final item = food;
    final kcal = item == null ? 0.0 : kcalFor(item, entry.grams);
    final protein = item == null ? 0.0 : macrosFor(item, entry.grams).proteinG;
    final price = item == null
        ? null
        : estimatedPrice(item, entry.grams, entry.servingsCount);
    final name = item?.nameEn ?? 'Planned food';
    final arabic = item?.nameAr;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(
                mealTypeIcon(entry.mealType),
                color: cs.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealTypeLabel(entry.mealType).toUpperCase(),
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
                  const SizedBox(height: 4),
                  Text(
                    '${shortPortion(entry.portion, entry.servingsCount)} · '
                    '${kcal.round()} kcal · P ${protein.round()}g',
                    style: text.bodySmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (entry.note != null && entry.note!.trim().isNotEmpty)
                    Text(
                      entry.note!,
                      style: text.bodySmall!.copyWith(color: cs.outline),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (price != null)
                  Text(
                    egp(price),
                    style: text.labelMedium!.copyWith(color: cs.secondary),
                  ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: FilledButton(
                    onPressed: isLogging ? null : onLog,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: isLogging
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('LOG'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

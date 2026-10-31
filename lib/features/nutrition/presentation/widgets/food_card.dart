import 'package:flutter/material.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/presentation/widgets/macro_chips_row.dart';

/// Search result card for the shared foods catalogue (mockup:
/// "Search Food Database"). Shows the bilingual name, kcal per 100 g,
/// indicative price and the per-100 g macro split, with a quick add
/// button that opens the portion picker.
class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.food,
    required this.onTap,
    this.onAdd,
  });

  final FoodItem food;
  final VoidCallback onTap;

  /// Opens the portion picker instead of the detail view when provided.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final n = food.per100g;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                          food.nameEn,
                          style: text.titleLarge!.copyWith(
                            color: cs.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (food.nameAr != null)
                          Text(
                            food.nameAr!,
                            style: text.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (onAdd != null)
                    IconButton.filled(
                      onPressed: onAdd,
                      tooltip: 'Quick add',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${n.energyKcal.toStringAsFixed(0)} kcal',
                    style: text.labelMedium!.copyWith(color: cs.primary),
                  ),
                  Text(
                    ' / 100 g',
                    style: text.labelMedium!
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (food.priceEgp != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      '${food.priceEgp!.toStringAsFixed(0)} EGP',
                      style: text.labelMedium!.copyWith(color: cs.primary),
                    ),
                    Text(
                      ' / ${food.priceBasis.name}',
                      style: text.labelMedium!
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                  if (food.isPriceStale) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.history,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'stale price',
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              MacroChipsRow(
                proteinG: n.proteinG,
                carbG: n.carbohydrateG,
                fatG: n.fatG,
              ),
              const SizedBox(height: 10),
              Text(
                food.category,
                style: text.labelSmall!.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

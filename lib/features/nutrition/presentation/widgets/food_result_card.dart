import 'package:flutter/material.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';

/// Search result card from the food catalogue. Matches the dense telemetry
/// cards in the reference design: bilingual name, energy, price and macros.
class FoodResultCard extends StatelessWidget {
  const FoodResultCard({
    super.key,
    required this.food,
    required this.onTap,
    required this.onAdd,
  });

  final FoodItem food;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final price = food.priceEgp;
    final arabic = food.nameAr;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              food.nameEn,
                              style: text.titleLarge!.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (arabic != null && arabic.trim().isNotEmpty)
                              Text(
                                '($arabic)',
                                textDirection: TextDirection.rtl,
                                style: text.bodyMedium!.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${food.per100g.energyKcal.round()} kcal / 100g',
                              style: text.labelMedium!.copyWith(
                                color: cs.primary,
                              ),
                            ),
                            if (price != null) ...[
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: cs.outline,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                '${price.toStringAsFixed(0)} EGP / ${_basisLabel(food)}',
                                style: text.labelMedium!.copyWith(
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _AddButton(onPressed: onAdd),
                ],
              ),
              if (food.isPriceStale && price != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Indicative price may be outdated',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MacroChip(
                    label: 'PROTEIN',
                    value: '${food.per100g.proteinG.round()}g',
                    color: cs.primary,
                  ),
                  _MacroChip(
                    label: 'CARBS',
                    value: '${food.per100g.carbohydrateG.round()}g',
                    color: cs.secondary,
                  ),
                  _MacroChip(
                    label: 'FAT',
                    value: '${food.per100g.fatG.round()}g',
                    color: cs.outline,
                  ),
                  if (food.category.trim().isNotEmpty)
                    _MacroChip(
                      label: 'CATEGORY',
                      value: food.category,
                      color: cs.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _basisLabel(FoodItem food) {
    return switch (food.priceBasis) {
      _ when food.priceBasis.name == 'weight' => 'kg',
      _ when food.priceBasis.name == 'drink' => 'drink',
      _ => 'serving',
    };
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 44,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(Icons.add, size: 22, color: cs.onPrimary),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

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
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$label:',
            style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall!.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}

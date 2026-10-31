import 'package:flutter/material.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';

/// Portion picker + serving multiplier used by the food detail sheet and the
/// meal-log editor.
class PortionSelector extends StatelessWidget {
  const PortionSelector({
    super.key,
    required this.food,
    required this.portion,
    required this.servings,
    required this.onPortionChanged,
    required this.onServingsChanged,
  });

  final FoodItem food;
  final Portion portion;
  final double servings;
  final ValueChanged<Portion> onPortionChanged;
  final ValueChanged<double> onServingsChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final portions = food.portions.isEmpty
        ? const [Portion(label: '100 g', grams: 100)]
        : food.portions;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'PORTION SIZE',
                  style: text.labelSmall!.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                '${gramsLabel(gramsFor(portion, servings))} total',
                style: text.labelMedium!.copyWith(color: cs.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in portions)
                _PortionChip(
                  label: item.label,
                  grams: item.grams,
                  selected: item == portion,
                  onTap: () => onPortionChanged(item),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                onTap: servings <= 0.5
                    ? null
                    : () => onServingsChanged((servings - 0.5).clamp(0.5, 20)),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      servings == servings.roundToDouble()
                          ? servings.round().toString()
                          : servings.toStringAsFixed(1),
                      style: text.headlineMedium!.copyWith(color: cs.primary),
                    ),
                    Text(
                      'SERVINGS',
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              _StepButton(
                icon: Icons.add,
                onTap: servings >= 20
                    ? null
                    : () => onServingsChanged((servings + 0.5).clamp(0.5, 20)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            portionSummary(portion, servings),
            style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PortionChip extends StatelessWidget {
  const _PortionChip({
    required this.label,
    required this.grams,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double grams;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final foreground = selected ? cs.onPrimary : cs.onSurfaceVariant;

    return Material(
      color: selected ? cs.primary : cs.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: text.labelMedium!.copyWith(color: foreground),
              ),
              Text(
                gramsLabel(grams),
                style: text.labelSmall!.copyWith(
                  color: selected
                      ? cs.onPrimary.withValues(alpha: 0.8)
                      : cs.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(icon, color: onTap == null ? cs.outline : cs.onSurface),
      ),
    );
  }
}

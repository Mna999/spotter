import 'package:flutter/material.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';

/// Horizontal / wrapped picker for the meal a food belongs to.
class MealTypeSelector extends StatelessWidget {
  const MealTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.types = MealType.values,
  });

  final MealType selected;
  final ValueChanged<MealType> onChanged;
  final List<MealType> types;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in types)
          _MealTypeChip(
            type: type,
            selected: type == selected,
            onTap: () => onChanged(type),
          ),
      ],
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  const _MealTypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final MealType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final foreground = selected ? cs.onPrimary : cs.onSurfaceVariant;

    return Material(
      color: selected ? cs.primary : cs.surfaceContainerLow,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(mealTypeIcon(type), size: 16, color: foreground),
              const SizedBox(width: 6),
              Text(
                mealTypeLabel(type),
                style: text.labelMedium!.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

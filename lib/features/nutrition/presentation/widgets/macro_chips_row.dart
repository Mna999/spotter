import 'package:flutter/material.dart';
import 'package:spotter/core/theme/app_theme.dart';

/// Row of the three headline macros (protein / carbs / fat) as compact
/// chips, mirroring the mockup's per-card macro telemetry row.
class MacroChipsRow extends StatelessWidget {
  const MacroChipsRow({super.key, required this.proteinG, required this.carbG, required this.fatG});

  final double proteinG;
  final double carbG;
  final double fatG;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    return Row(
      children: [
        _MacroChip(
          label: 'PROTEIN',
          grams: proteinG,
          color: cs.primary,
        ),
        const SizedBox(width: 6),
        _MacroChip(label: 'CARBS', grams: carbG, color: appColors.carbs),
        const SizedBox(width: 6),
        _MacroChip(label: 'FAT', grams: fatG, color: appColors.warning),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.grams,
    required this.color,
  });

  final String label;
  final double grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
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
            '$label ${grams.toStringAsFixed(0)}g',
            style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

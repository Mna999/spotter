import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/theme/app_theme.dart';

/// Metabolic target card (mockup: "Your Metabolic Target").
///
/// Big daily calorie goal on top, then the protein / carbs / fat split
/// with a segmented share bar underneath.
class MacroTargetCard extends StatelessWidget {
  const MacroTargetCard({
    super.key,
    required this.targetKcal,
    required this.targetProteinG,
    required this.targetCarbG,
    required this.targetFatG,
    this.subtitle,
  });

  final double targetKcal;
  final double targetProteinG;
  final double targetCarbG;
  final double targetFatG;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    final proteinKcal = targetProteinG * 4;
    final carbKcal = targetCarbG * 4;
    final fatKcal = targetFatG * 9;
    final totalMacroKcal = proteinKcal + carbKcal + fatKcal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'DAILY CALORIE GOAL',
                    style: text.labelSmall!.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        DateFormatter.thousands(targetKcal),
                        style: text.headlineLarge!.copyWith(
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'kcal/day',
                        style: text.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: text.bodySmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'MACRO TARGETS',
              style: text.labelSmall!.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    Expanded(
                      flex: totalMacroKcal == 0
                          ? 1
                          : (proteinKcal / totalMacroKcal * 100).round(),
                      child: ColoredBox(color: cs.primary),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: totalMacroKcal == 0
                          ? 1
                          : (carbKcal / totalMacroKcal * 100).round(),
                      child: ColoredBox(color: appColors.carbs),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: totalMacroKcal == 0
                          ? 1
                          : (fatKcal / totalMacroKcal * 100).round(),
                      child: ColoredBox(color: appColors.warning),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _TargetRow(
              grams: targetProteinG,
              label: 'Protein',
              color: cs.primary,
            ),
            _TargetRow(
              grams: targetCarbG,
              label: 'Carbs',
              color: appColors.carbs,
            ),
            _TargetRow(
              grams: targetFatG,
              label: 'Fats',
              color: appColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.grams,
    required this.label,
    required this.color,
  });

  final double grams;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${grams.toStringAsFixed(0)} g ${label}',
                style: text.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/theme/app_theme.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';

class MacroGoalsCard extends StatelessWidget {
  const MacroGoalsCard({
    super.key,
    required this.macroTargets,
    required this.tdee,
    required this.bmi,
    required this.goal,
  });

  final MacroTargets macroTargets;
  final double tdee;
  final double bmi;
  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final proteinKcal = macroTargets.proteinG * 4;
    final carbsKcal = macroTargets.carbsG * 4;
    final fatKcal = macroTargets.fatG * 9;
    final totalKcal = proteinKcal + carbsKcal + fatKcal;

    final proteinShare = totalKcal == 0 ? 0.0 : proteinKcal / totalKcal;
    final carbsShare = totalKcal == 0 ? 0.0 : carbsKcal / totalKcal;
    final fatShare = totalKcal == 0 ? 0.0 : fatKcal / totalKcal;
    final fatColor = context.appColors.warning;
    final carbsColor = context.appColors.carbs;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE EXPENDITURE',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('Macro Goals', style: text.titleLarge),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    _goalLabel(goal),
                    style: text.labelSmall!.copyWith(color: cs.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(132, 132),
                        painter: _MacroDonutPainter(
                          trackColor: cs.primaryContainer,
                          proteinColor: cs.primary,
                          carbsColor: carbsColor,
                          fatColor: fatColor,
                          proteinShare: proteinShare,
                          carbsShare: carbsShare,
                          fatShare: fatShare,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormatter.thousands(macroTargets.calories),
                            style: text.headlineMedium!.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            'KCAL / DAY',
                            style: text.labelSmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetricRow(
                        label: 'TDEE',
                        value: '${DateFormatter.thousands(tdee)} kcal',
                      ),
                      const SizedBox(height: 8),
                      _MetricRow(label: 'BMI', value: bmi.toStringAsFixed(1)),
                      const SizedBox(height: 8),
                      _MetricRow(
                        label: 'Protein',
                        value: '${macroTargets.proteinG} g',
                      ),
                      const SizedBox(height: 8),
                      _MetricRow(
                        label: 'Carbs',
                        value: '${macroTargets.carbsG} g',
                      ),
                      const SizedBox(height: 8),
                      _MetricRow(label: 'Fat', value: '${macroTargets.fatG} g'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MacroTile(
                    label: 'PROTEIN',
                    grams: macroTargets.proteinG,
                    share: proteinShare,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroTile(
                    label: 'CARBS',
                    grams: macroTargets.carbsG,
                    share: carbsShare,
                    color: carbsColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroTile(
                    label: 'FAT',
                    grams: macroTargets.fatG,
                    share: fatShare,
                    color: fatColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _goalLabel(Goal goal) => switch (goal) {
    Goal.loseFat => 'CUT',
    Goal.maintain => 'MAINTAIN',
    Goal.buildMuscle => 'BULK',
  };
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: text.bodyMedium!.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.grams,
    required this.share,
    required this.color,
  });

  final String label;
  final int grams;
  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$grams',
                style: text.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 2),
              Text(
                'g',
                style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: share.clamp(0.0, 1.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroDonutPainter extends CustomPainter {
  const _MacroDonutPainter({
    required this.trackColor,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
    required this.proteinShare,
    required this.carbsShare,
    required this.fatShare,
  });

  final Color trackColor;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;
  final double proteinShare;
  final double carbsShare;
  final double fatShare;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, track);

    const gap = 0.04;
    var start = -math.pi / 2;

    void drawShare(double share, Color color) {
      if (share <= 0) return;
      final sweep = share * (2 * math.pi);
      if (sweep <= gap) return;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, start + gap / 2, sweep - gap, false, paint);
      start += sweep;
    }

    drawShare(proteinShare, proteinColor);
    drawShare(carbsShare, carbsColor);
    drawShare(fatShare, fatColor);
  }

  @override
  bool shouldRepaint(covariant _MacroDonutPainter oldDelegate) {
    return oldDelegate.proteinShare != proteinShare ||
        oldDelegate.carbsShare != carbsShare ||
        oldDelegate.fatShare != fatShare ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.proteinColor != proteinColor ||
        oldDelegate.carbsColor != carbsColor ||
        oldDelegate.fatColor != fatColor;
  }
}

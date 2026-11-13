import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';

/// Aggregated numbers for every plan shown in the meal-plan list.
class MealPlanSummary extends Equatable {
  final MacroNutrients totals;
  final double spentEgp;
  final int itemCount;

  const MealPlanSummary({
    this.totals = MacroNutrients.zero,
    this.spentEgp = 0,
    this.itemCount = 0,
  });

  @override
  List<Object?> get props => [totals, spentEgp, itemCount];
}

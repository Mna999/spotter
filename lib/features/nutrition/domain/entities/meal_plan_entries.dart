import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/services/nutrition_calculator.dart';

/// The entries of one meal plan together with the foods they reference and
/// the aggregates the plan detail screen renders.
class MealPlanEntries extends Equatable {
  final List<MealEntry> entries;
  final Map<String, FoodItem> foods;
  final MacroNutrients totals;
  final double spentEgp;

  const MealPlanEntries({
    this.entries = const <MealEntry>[],
    this.foods = const <String, FoodItem>{},
    this.totals = MacroNutrients.zero,
    this.spentEgp = 0,
  });

  /// Builds the value and derives its totals from [entries] and [foods].
  factory MealPlanEntries.from({
    required List<MealEntry> entries,
    required Map<String, FoodItem> foods,
  }) {
    return MealPlanEntries(
      entries: entries,
      foods: foods,
      totals: NutritionCalculator.macrosForEntries(entries, foods),
      spentEgp: NutritionCalculator.estimatedCostForEntries(entries, foods),
    );
  }

  bool get isEmpty => entries.isEmpty;

  int get itemCount => entries.length;

  /// Entries grouped by meal, each group ordered by its stored position.
  List<MealEntryGroup> get mealGroups {
    final groups = <MealType, List<MealEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(entry.mealType, () => <MealEntry>[]).add(entry);
    }
    final types = groups.keys.toList()..sort((a, b) => a.index.compareTo(b.index));
    return [
      for (final type in types)
        MealEntryGroup(
          mealType: type,
          entries: groups[type]!..sort((a, b) => a.order.compareTo(b.order)),
        ),
    ];
  }

  @override
  List<Object?> get props => [entries, foods, totals, spentEgp];
}

/// The entries of one meal inside a [MealPlanEntries].
class MealEntryGroup extends Equatable {
  final MealType mealType;
  final List<MealEntry> entries;

  const MealEntryGroup({required this.mealType, required this.entries});

  @override
  List<Object?> get props => [mealType, entries];
}

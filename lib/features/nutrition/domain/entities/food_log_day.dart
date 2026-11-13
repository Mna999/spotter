import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/services/nutrition_calculator.dart';

/// A calendar day of food logs together with the catalogue foods they
/// reference and the aggregates the dashboard renders.
class FoodLogDay extends Equatable {
  final DateTime date;
  final List<MealLog> logs;
  final Map<String, FoodItem> foods;
  final MacroNutrients totals;
  final double spentEgp;

  const FoodLogDay({
    required this.date,
    this.logs = const <MealLog>[],
    this.foods = const <String, FoodItem>{},
    this.totals = MacroNutrients.zero,
    this.spentEgp = 0,
  });

  /// Builds a day and derives its totals from [logs] and [foods].
  factory FoodLogDay.from({
    required DateTime date,
    required List<MealLog> logs,
    required Map<String, FoodItem> foods,
  }) {
    return FoodLogDay(
      date: date,
      logs: logs,
      foods: foods,
      totals: NutritionCalculator.macrosForLogs(logs, foods),
      spentEgp: NutritionCalculator.estimatedCostForLogs(logs, foods),
    );
  }

  bool get isEmpty => logs.isEmpty;

  int get logCount => logs.length;

  /// Logs grouped by meal, in the canonical meal order.
  List<MealLogGroup> get mealGroups {
    final groups = <MealType, List<MealLog>>{};
    for (final log in logs) {
      groups.putIfAbsent(log.mealType, () => <MealLog>[]).add(log);
    }
    final types = groups.keys.toList()..sort((a, b) => a.index.compareTo(b.index));
    return [
      for (final type in types)
        MealLogGroup(
          mealType: type,
          logs: groups[type]!,
          kcal: _kcalFor(groups[type]!),
        ),
    ];
  }

  double _kcalFor(List<MealLog> groupLogs) {
    var total = 0.0;
    for (final log in groupLogs) {
      final food = foods[log.foodId];
      total += food == null
          ? log.computedKcal
          : NutritionCalculator.kcalFor(food, log.grams);
    }
    return total;
  }

  @override
  List<Object?> get props => [date, logs, foods, totals, spentEgp];
}

/// The logs of one meal inside a [FoodLogDay].
class MealLogGroup extends Equatable {
  final MealType mealType;
  final List<MealLog> logs;

  /// Energy of the whole group.
  final double kcal;

  const MealLogGroup({
    required this.mealType,
    required this.logs,
    required this.kcal,
  });

  @override
  List<Object?> get props => [mealType, logs, kcal];
}

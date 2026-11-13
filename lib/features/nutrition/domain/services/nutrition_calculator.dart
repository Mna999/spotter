import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/entities/price_basis.dart';

/// Nutrition arithmetic shared by the use cases. Keeping it in the domain
/// layer means the dashboard, the meal planner and the food picker all derive
/// the same numbers from the same food document.
class NutritionCalculator {
  const NutritionCalculator._();

  /// Macros contributed by [grams] of [food].
  static MacroNutrients macrosFor(FoodItem food, double grams) =>
      food.per100g.scale(grams / 100);

  /// Energy contributed by [grams] of [food].
  static double kcalFor(FoodItem food, double grams) =>
      food.per100g.energyKcal * grams / 100;

  /// Rough EGP impact of a portion. Prices are indicative and depend on the
  /// catalogue's [PriceBasis].
  static double? estimatedPrice(FoodItem food, double grams, double servings) {
    final price = food.priceEgp;
    if (price == null) return null;
    return switch (food.priceBasis) {
      PriceBasis.weight => price * grams / 1000,
      PriceBasis.serving => price * servings,
      PriceBasis.drink => price * servings,
    };
  }

  /// Sums the macros of the logs whose food is present in [foods].
  static MacroNutrients macrosForLogs(
    Iterable<MealLog> logs,
    Map<String, FoodItem> foods,
  ) {
    var total = MacroNutrients.zero;
    for (final log in logs) {
      final food = foods[log.foodId];
      total = total +
          (food == null
              ? MacroNutrients.energyOnly(log.computedKcal)
              : macrosFor(food, log.grams));
    }
    return total;
  }

  /// Sums the macros of the entries whose food is present in [foods].
  static MacroNutrients macrosForEntries(
    Iterable<MealEntry> entries,
    Map<String, FoodItem> foods,
  ) {
    var total = MacroNutrients.zero;
    for (final entry in entries) {
      final food = foods[entry.foodId];
      if (food == null) continue;
      total = total + macrosFor(food, entry.grams);
    }
    return total;
  }

  /// Indicative EGP cost of the logs whose food is present in [foods].
  static double estimatedCostForLogs(
    Iterable<MealLog> logs,
    Map<String, FoodItem> foods,
  ) {
    var total = 0.0;
    for (final log in logs) {
      final food = foods[log.foodId];
      if (food == null) continue;
      total += estimatedPrice(food, log.grams, log.servingsCount) ?? 0;
    }
    return total;
  }

  /// Indicative EGP cost of the entries whose food is present in [foods].
  static double estimatedCostForEntries(
    Iterable<MealEntry> entries,
    Map<String, FoodItem> foods,
  ) {
    var total = 0.0;
    for (final entry in entries) {
      final food = foods[entry.foodId];
      if (food == null) continue;
      total += estimatedPrice(food, entry.grams, entry.servingsCount) ?? 0;
    }
    return total;
  }
}

import 'package:flutter/material.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/entities/price_basis.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';
import 'package:spotter/injection_container.dart';

/// What the food detail screen should do with the selected food.
enum FoodActionMode { log, addToPlan }

/// Presentation helpers shared by the nutrition screens. Keeping the math in
/// one place makes the dashboard, the portion picker and the meal planner show
/// exactly the same numbers for the same food.

String mealTypeLabel(MealType type) => switch (type) {
  MealType.breakfast => 'Breakfast',
  MealType.lunch => 'Lunch',
  MealType.dinner => 'Dinner',
  MealType.snack => 'Snack',
  MealType.preWorkout => 'Pre-workout',
  MealType.postWorkout => 'Post-workout',
};

String mealTypeArabicLabel(MealType type) => switch (type) {
  MealType.breakfast => 'الفطور',
  MealType.lunch => 'الغداء',
  MealType.dinner => 'العشاء',
  MealType.snack => 'وجبة خفيفة',
  MealType.preWorkout => 'قبل التمرين',
  MealType.postWorkout => 'بعد التمرين',
};

IconData mealTypeIcon(MealType type) => switch (type) {
  MealType.breakfast => Icons.free_breakfast_outlined,
  MealType.lunch => Icons.lunch_dining_outlined,
  MealType.dinner => Icons.dinner_dining_outlined,
  MealType.snack => Icons.cookie_outlined,
  MealType.preWorkout => Icons.bolt_outlined,
  MealType.postWorkout => Icons.fitness_center,
};

int mealTypeOrder(MealType type) => switch (type) {
  MealType.breakfast => 0,
  MealType.lunch => 1,
  MealType.dinner => 2,
  MealType.snack => 3,
  MealType.preWorkout => 4,
  MealType.postWorkout => 5,
};

String planStatusLabel(PlanStatus status) => switch (status) {
  PlanStatus.draft => 'DRAFT',
  PlanStatus.committed => 'COMMITTED',
  PlanStatus.archived => 'ARCHIVED',
};

Portion defaultPortionFor(FoodItem food) {
  if (food.portions.isNotEmpty) return food.portions.first;
  return const Portion(label: '100 g', grams: 100);
}

/// The consumed mass of a log/entry, in grams.
double gramsFor(Portion portion, double servings) =>
    portion.grams * servings;

MacroNutrients macrosFor(FoodItem food, double grams) =>
    food.per100g.scale(grams / 100);

double kcalFor(FoodItem food, double grams) =>
    food.per100g.energyKcal * grams / 100;

/// Sums the macros of the logs whose food is present in [foods].
MacroNutrients macrosForLogs(
  Iterable<MealLog> logs,
  Map<String, FoodItem> foods,
) {
  var total = MacroNutrients.zero;
  for (final log in logs) {
    final food = foods[log.foodId];
    if (food == null) {
      total = total + MacroNutrients.energyOnly(log.computedKcal);
    } else {
      total = total + macrosFor(food, gramsFor(log.portion, log.servingsCount));
    }
  }
  return total;
}

/// Rough EGP impact of a portion. Prices are indicative and depend on the
/// catalogue's [PriceBasis].
double? estimatedPrice(FoodItem food, double grams, double servings) {
  final price = food.priceEgp;
  if (price == null) return null;
  return switch (food.priceBasis) {
    PriceBasis.weight => price * grams / 1000,
    PriceBasis.serving => price * servings,
    PriceBasis.drink => price * servings,
  };
}

String egp(num? value) {
  if (value == null) return '—';
  if (value == value.roundToDouble()) return '${value.round()} EGP';
  return '${value.toStringAsFixed(1)} EGP';
}

String kcal(num value) => '${value.round()} kcal';

String gramsLabel(double value) {
  if (value == value.roundToDouble()) return '${value.round()} g';
  return '${value.toStringAsFixed(1)} g';
}

String portionSummary(Portion portion, double servings) {
  final label = portion.label.trim();
  final multiplier = servings == servings.roundToDouble()
      ? servings.round().toString()
      : servings.toStringAsFixed(1);
  return '$multiplier × $label (${gramsLabel(gramsFor(portion, servings))})';
}

String shortPortion(Portion portion, double servings) {
  final multiplier = servings == servings.roundToDouble()
      ? servings.round().toString()
      : servings.toStringAsFixed(1);
  return '$multiplier× ${portion.label}';
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String friendlyDate(DateTime date) {
  final today = dateOnly(DateTime.now());
  final target = dateOnly(date);
  final difference = target.difference(today).inDays;
  if (difference == 0) return 'Today';
  if (difference == -1) return 'Yesterday';
  if (difference == 1) return 'Tomorrow';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

MealPlan copyMealPlan(
  MealPlan plan, {
  String? mealPlanId,
  DateTime? date,
  double? budgetEgp,
  double? totalKcal,
  double? costEgp,
  PlanStatus? status,
}) {
  return MealPlan(
    mealPlanId: mealPlanId ?? plan.mealPlanId,
    uid: plan.uid,
    date: date ?? plan.date,
    budgetEgp: budgetEgp ?? plan.budgetEgp,
    totalKcal: totalKcal ?? plan.totalKcal,
    costEgp: costEgp ?? plan.costEgp,
    status: status ?? plan.status,
    schemaVersion: plan.schemaVersion,
    createdAt: plan.createdAt,
    updatedAt: DateTime.now(),
  );
}

/// Sums the macros of the entries whose food is present in [foods].
MacroNutrients macrosForEntries(
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
double estimatedCostForLogs(
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
double estimatedCostForEntries(
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

/// Fetches the foods with the given ids. Foods that are missing from the
/// catalogue (or that fail to load) are simply omitted.
Future<Map<String, FoodItem>> fetchFoodsById(Iterable<String> foodIds) async {
  final ids = foodIds.toSet();
  if (ids.isEmpty) return const {};
  final repo = sl<FoodRepo>();
  final results = await Future.wait(
    ids.map((id) => repo.getById(foodId: id)),
  );
  final foods = <String, FoodItem>{};
  for (final result in results) {
    result.fold((_) {}, (food) {
      if (food != null) foods[food.foodId] = food;
    });
  }
  return foods;
}

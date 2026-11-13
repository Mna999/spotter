import 'package:flutter/material.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/services/nutrition_calculator.dart';

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

int mealTypeOrder(MealType type) => type.index;

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
    NutritionCalculator.macrosFor(food, grams);

double kcalFor(FoodItem food, double grams) =>
    NutritionCalculator.kcalFor(food, grams);

/// Rough EGP impact of a portion. Prices are indicative and depend on the
/// catalogue's `PriceBasis`.
double? estimatedPrice(FoodItem food, double grams, double servings) =>
    NutritionCalculator.estimatedPrice(food, grams, servings);

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

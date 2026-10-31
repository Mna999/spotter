import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';

/// One food inside a meal plan
/// (Firestore: `users/{uid}/mealPlans/{planId}/entries/{entryId}`).
class MealEntry extends Equatable {
  final String mealEntryId;
  final String mealPlanId;
  final String uid;
  final String foodId;
  final MealType mealType;

  /// Position within the meal type.
  final int order;
  final Portion portion;

  /// Multiplier applied to the food's per-100 g values.
  final double servingsCount;
  final String? note;
  final int schemaVersion;
  final DateTime createdAt;

  /// Null until the entry has been edited after creation.
  final DateTime? updatedAt;

  const MealEntry({
    required this.mealEntryId,
    required this.mealPlanId,
    required this.uid,
    required this.foodId,
    required this.mealType,
    required this.order,
    required this.portion,
    required this.servingsCount,
    this.note,
    required this.schemaVersion,
    required this.createdAt,
    this.updatedAt,
  });

  /// Consumed mass in grams.
  double get grams => portion.grams * servingsCount;

  @override
  List<Object?> get props => [
    mealEntryId,
    mealPlanId,
    uid,
    foodId,
    mealType,
    order,
    portion,
    servingsCount,
    note,
    schemaVersion,
    createdAt,
    updatedAt,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';

/// A food actually eaten (Firestore: `users/{uid}/mealLogs/{mealLogId}`).
class MealLog extends Equatable {
  final String mealLogId;
  final String uid;
  final String foodId;
  final MealType mealType;
  final Portion portion;

  /// Multiplier applied to the food's per-100 g values.
  final double servingsCount;

  /// Denormalised energy so day totals never need to join the catalogue.
  final double computedKcal;
  final DateTime loggedAt;
  final String? note;
  final int schemaVersion;
  final DateTime createdAt;

  /// Null until the log has been edited after creation.
  final DateTime? updatedAt;

  const MealLog({
    required this.mealLogId,
    required this.uid,
    required this.foodId,
    required this.mealType,
    required this.portion,
    required this.servingsCount,
    required this.computedKcal,
    required this.loggedAt,
    this.note,
    required this.schemaVersion,
    required this.createdAt,
    this.updatedAt,
  });

  /// Consumed mass in grams.
  double get grams => portion.grams * servingsCount;
  
  @override
  List<Object?> get props => [
    mealLogId,
    uid,
    foodId,
    mealType,
    portion,
    servingsCount,
    computedKcal,
    loggedAt,
    note,
    schemaVersion,
    createdAt,
    updatedAt,
  ];
}

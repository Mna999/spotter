import 'package:equatable/equatable.dart';

/// One document per user (Firestore: `users/{uid}/dietaryPrefs`).
class DietaryPreferences extends Equatable {
  /// Primary key, equal to the Firestore document id (`users/{uid}`).
  final String uid;
  final Set<String> excludedFoodIds;
  final Set<String> excludedCategories;
  final double targetKcal;
  final double targetProteinG;
  final double targetCarbG;
  final double targetFatG;
  final double? budgetEgp;

  /// Free-form diet tag, e.g. `vegan`, `halal`, `vegetarian`.
  final String? dietTag;
  final int schemaVersion;
  final DateTime createdAt;

  /// Null until the preferences have been edited after creation.
  final DateTime? updatedAt;

  const DietaryPreferences({
    required this.uid,
    required this.excludedFoodIds,
    required this.excludedCategories,
    required this.targetKcal,
    required this.targetProteinG,
    required this.targetCarbG,
    required this.targetFatG,
    this.budgetEgp,
    this.dietTag,
    required this.schemaVersion,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    uid,
    excludedFoodIds,
    excludedCategories,
    targetKcal,
    targetProteinG,
    targetCarbG,
    targetFatG,
    budgetEgp,
    dietTag,
    schemaVersion,
    createdAt,
    updatedAt,
  ];
}

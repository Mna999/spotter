import 'package:equatable/equatable.dart';

/// Per-user nutrition settings (Firestore:
/// `users/{uid}/dietaryPreferences/{uid}`).
///
/// Calorie and macro goals are derived from the user's profile
/// (`ProfileBloc` -> `BodyMetrics.macroTargets`) and are deliberately not
/// stored here. This document only holds the planner guardrails and the EGP
/// budget.
class DietaryPreferences extends Equatable {
  /// Primary key, equal to the Firestore document id (the user's uid).
  final String uid;
  final String prefsId;
  final Set<String> excludedFoodIds;
  final Set<String> excludedCategories;
  final double? budgetEgp;

  /// Free-form diet tag, e.g. `vegan`, `halal`, `vegetarian`.
  final String? dietTag;
  final int schemaVersion;
  final DateTime createdAt;

  /// Null until the preferences have been edited after creation.
  final DateTime? updatedAt;

  const DietaryPreferences({
    required this.prefsId,
    required this.uid,
    required this.excludedFoodIds,
    required this.excludedCategories,
    this.budgetEgp,
    this.dietTag,
    required this.schemaVersion,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    uid,
    prefsId,
    excludedFoodIds,
    excludedCategories,
    budgetEgp,
    dietTag,
    schemaVersion,
    createdAt,
    updatedAt,
  ];
}

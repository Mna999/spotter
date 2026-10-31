import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';

/// A user's plan for one day (Firestore: `users/{uid}/mealPlans/{mealPlanId}`).
///
/// Meal entries are not embedded: they live in the `entries` subcollection to
/// stay clear of Firestore's 1 MiB document limit.
class MealPlan extends Equatable {
  final String mealPlanId;
  final String uid;

  /// The planned day (time part is meaningless).
  final DateTime date;

  /// Soft daily cost cap in EGP.
  final double? budgetEgp;

  /// Computed from the entries of the plan.
  final double totalKcal;

  /// Computed from the entries of the plan.
  final double costEgp;
  final PlanStatus status;
  final int schemaVersion;
  final DateTime createdAt;

  /// Null until the plan has been modified after creation.
  final DateTime? updatedAt;

  const MealPlan({
    required this.mealPlanId,
    required this.uid,
    required this.date,
    this.budgetEgp,
    required this.totalKcal,
    required this.costEgp,
    required this.status,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  /// FR-NUT-06: whether the plan exceeds its (optional) cost ceiling.
  bool get isOverBudget {
    final budget = budgetEgp;
    return budget != null && costEgp > budget;
  }

  @override
  List<Object?> get props => [
    mealPlanId,
    uid,
    date,
    budgetEgp,
    totalKcal,
    costEgp,
    status,
    schemaVersion,
    createdAt,
    updatedAt,
  ];
}

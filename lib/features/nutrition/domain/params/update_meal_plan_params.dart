import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';

class UpdateMealPlanParams extends Equatable {
  final String uid;
  final String mealPlanId;
  final String? name;
  final DateTime? date;
  final double? budgetEgp;
  final double? totalKcal;
  final double? costEgp;
  final PlanStatus? status;

  const UpdateMealPlanParams({
    required this.uid,
    required this.mealPlanId,
    this.name,
    this.date,
    this.budgetEgp,
    this.totalKcal,
    this.costEgp,
    this.status,
  });

  @override
  List<Object?> get props => [
    uid,
    mealPlanId,
    name,
    date,
    budgetEgp,
    totalKcal,
    costEgp,
    status,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';

class UpdateMealPlanParams extends Equatable {
  final String uid;
  final String mealPlanId;
  final double? totalKcal;
  final double? costEgp;
  final PlanStatus? status;

  const UpdateMealPlanParams({
    required this.uid,
    required this.mealPlanId,
    this.totalKcal,
    this.costEgp,
    this.status,
  });

  @override
  List<Object?> get props => [uid, mealPlanId, totalKcal, costEgp, status];
}

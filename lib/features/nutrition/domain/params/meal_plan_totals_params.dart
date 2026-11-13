import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';

class MealPlanTotalsParams extends Equatable {
  final String uid;
  final MealPlan plan;

  const MealPlanTotalsParams({required this.uid, required this.plan});

  @override
  List<Object?> get props => [uid, plan];
}

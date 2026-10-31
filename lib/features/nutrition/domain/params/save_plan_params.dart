import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';

class SavePlanParams extends Equatable {
  final String uid;
  final MealPlan mealPlan;

  const SavePlanParams({required this.uid, required this.mealPlan});

  @override
  List<Object?> get props => [uid, mealPlan];
}

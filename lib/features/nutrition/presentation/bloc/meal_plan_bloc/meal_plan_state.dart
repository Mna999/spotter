part of 'meal_plan_bloc.dart';

abstract class MealPlanState extends Equatable {
  const MealPlanState();
  @override
  List<Object?> get props => [];
}

class MealPlanInitial extends MealPlanState {
  const MealPlanInitial();
}

class MealPlanEmpty extends MealPlanState {
  final String? message;
  const MealPlanEmpty({this.message});
  @override
  List<Object?> get props => [message];
}

class MealPlanLoading extends MealPlanState {
  const MealPlanLoading();
}

class MealPlanLoaded extends MealPlanState {
  final MealPlan? mealPlan;
  final List<MealPlan> plans;
  final List<MealEntry> entries;
  final String? message;
  const MealPlanLoaded({
    this.mealPlan,
    this.plans = const [],
    this.entries = const [],
    this.message,
  });
  @override
  List<Object?> get props => [mealPlan, plans, entries, message];
}

class MealPlanSaved extends MealPlanState {
  final MealPlan mealPlan;
  const MealPlanSaved({required this.mealPlan});
  @override
  List<Object?> get props => [mealPlan];
}

class MealPlanError extends MealPlanState {
  final String message;
  const MealPlanError({required this.message});
  @override
  List<Object?> get props => [message];
}

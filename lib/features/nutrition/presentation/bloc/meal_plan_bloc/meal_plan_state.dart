part of 'meal_plan_bloc.dart';

abstract class MealPlanState extends Equatable {
  const MealPlanState();
  @override
  List<Object?> get props => [];
}

class MealPlanInitial extends MealPlanState {
  const MealPlanInitial();
}

class MealEntriesLoading extends MealPlanState {
  const MealEntriesLoading();

  @override
  List<Object?> get props => [];
}

class MealEntriesLoaded extends MealPlanState {
  final MealPlanEntries data;

  const MealEntriesLoaded({required this.data});

  List<MealEntry> get entries => data.entries;
  Map<String, FoodItem> get foods => data.foods;
  MacroNutrients get totals => data.totals;
  double get spentEgp => data.spentEgp;
  List<MealEntryGroup> get mealGroups => data.mealGroups;

  @override
  List<Object?> get props => [data];
}

class MealEntriesError extends MealPlanState {
  final String message;

  const MealEntriesError({required this.message});

  @override
  List<Object?> get props => [message];
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

  /// Aggregated totals of every listed plan.
  final MealPlanSummary summary;
  final List<MealEntry> entries;
  final String? message;

  const MealPlanLoaded({
    this.mealPlan,
    this.plans = const [],
    this.summary = const MealPlanSummary(),
    this.entries = const [],
    this.message,
  });

  @override
  List<Object?> get props => [mealPlan, plans, summary, entries, message];
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

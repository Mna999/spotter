part of 'meal_plan_bloc.dart';

abstract class MealPlanEvent extends Equatable {
  const MealPlanEvent();
  @override
  List<Object?> get props => [];
}

class MealPlanCreated extends MealPlanEvent {
  final String uid;
  final DateTime date;
  final double? budgetEgp;
  const MealPlanCreated({
    required this.uid,
    required this.date,
    this.budgetEgp,
  });
  @override
  List<Object?> get props => [uid, date, budgetEgp];
}

class PlanGenerated extends MealPlanEvent {
  final String uid;
  final String prefsId;
  const PlanGenerated({required this.uid,required this.prefsId});
  @override
  List<Object?> get props => [uid];
}

class PlanRegeneratedUnderBudget extends MealPlanEvent {
  final String uid;
  final String prefsId;
  final double budgetEgp;
  const PlanRegeneratedUnderBudget({
    required this.uid,
    required this.budgetEgp,
    required this.prefsId
  });
  @override
  List<Object?> get props => [uid, budgetEgp,prefsId];
}

class PlanSaved extends MealPlanEvent {
  final String uid;
  final MealPlan mealPlan;
  const PlanSaved({required this.uid, required this.mealPlan});
  @override
  List<Object?> get props => [uid, mealPlan];
}

class PlanLoaded extends MealPlanEvent {
  final String uid;
  final String mealPlanId;
  const PlanLoaded({required this.uid, required this.mealPlanId});
  @override
  List<Object?> get props => [uid, mealPlanId];
}

class PlanUpdated extends MealPlanEvent {
  final UpdateMealPlanParams params;
  const PlanUpdated(this.params);
  @override
  List<Object?> get props => [params];
}

class PlanDeleted extends MealPlanEvent {
  final String uid;
  final String mealPlanId;
  const PlanDeleted({required this.uid, required this.mealPlanId});
  @override
  List<Object?> get props => [uid, mealPlanId];
}

class MealPlanListRequested extends MealPlanEvent {
  final String uid;
  final int limit;
  final String? cursor;
  const MealPlanListRequested({
    required this.uid,
    this.limit = 20,
    this.cursor,
  });
  @override
  List<Object?> get props => [uid, limit, cursor];
}

class MealEntryAdded extends MealPlanEvent {
  final AddMealEntryParams params;
  final MealPlan mealPlan;
  const MealEntryAdded({required this.params, required this.mealPlan});
  @override
  List<Object?> get props => [params, mealPlan];
}

class MealEntryUpdated extends MealPlanEvent {
  final String mealEntryId;
  const MealEntryUpdated({required this.mealEntryId});
  @override
  List<Object?> get props => [mealEntryId];
}

class MealEntryRemoved extends MealPlanEvent {
  final String mealEntryId;
  const MealEntryRemoved({required this.mealEntryId});
  @override
  List<Object?> get props => [mealEntryId];
}

class ExclusionsChanged extends MealPlanEvent {
  final String uid;
  final Set<String> excludedFoodIds;
  const ExclusionsChanged({required this.uid, required this.excludedFoodIds});
  @override
  List<Object?> get props => [uid, excludedFoodIds];
}

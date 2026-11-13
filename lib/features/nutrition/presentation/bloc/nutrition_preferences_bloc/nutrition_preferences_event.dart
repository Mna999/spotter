part of 'nutrition_preferences_bloc.dart';

abstract class NutritionPreferencesEvent extends Equatable {
  const NutritionPreferencesEvent();

  @override
  List<Object?> get props => [];
}

class NutritionPreferencesRequested extends NutritionPreferencesEvent {
  final String uid;
  final String prefsId;

  const NutritionPreferencesRequested({required this.uid,required this.prefsId});

  @override
  List<Object?> get props => [uid,prefsId];
}

class NutritionPreferencesSaved extends NutritionPreferencesEvent {
  final String uid;
  final DietaryPreferences preferences;

  const NutritionPreferencesSaved({
    required this.uid,
    required this.preferences,
  });

  @override
  List<Object?> get props => [uid, preferences];
}

class NutritionExclusionsUpdated extends NutritionPreferencesEvent {
  final String uid;
  final String prefsId;
  final Set<String> excludedFoodIds;
  final Set<String>? excludedCategories;

  const NutritionExclusionsUpdated({
    required this.uid,
    required this.excludedFoodIds,
    required this.prefsId,
    this.excludedCategories,
  });

  @override
  List<Object?> get props => [
    uid,
    excludedFoodIds,
    prefsId,
    excludedCategories,
  ];
}

class NutritionPlannerSettingsUpdated extends NutritionPreferencesEvent {
  final String uid;
  final String prefsId;
  final double? budgetEgp;
  final String? dietTag;

  const NutritionPlannerSettingsUpdated({
    required this.uid,
    required this.prefsId,
    this.budgetEgp,
    this.dietTag,
  });

  @override
  List<Object?> get props => [uid, prefsId, budgetEgp, dietTag];
}

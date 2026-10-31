part of 'nutrition_preferences_bloc.dart';

abstract class NutritionPreferencesState extends Equatable {
  const NutritionPreferencesState();

  @override
  List<Object?> get props => [];
}

class NutritionPreferencesInitial extends NutritionPreferencesState {
  const NutritionPreferencesInitial();
}

class NutritionPreferencesLoading extends NutritionPreferencesState {
  const NutritionPreferencesLoading();
}

class NutritionPreferencesLoaded extends NutritionPreferencesState {
  /// Null when the user has never saved dietary preferences.
  final DietaryPreferences? preferences;

  const NutritionPreferencesLoaded({this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class NutritionPreferencesSavedState extends NutritionPreferencesState {
  final DietaryPreferences preferences;
  final String? message;

  const NutritionPreferencesSavedState({
    required this.preferences,
    this.message,
  });

  @override
  List<Object?> get props => [preferences, message];
}

class NutritionPreferencesError extends NutritionPreferencesState {
  final String message;

  const NutritionPreferencesError({required this.message});

  @override
  List<Object?> get props => [message];
}

extension NutritionPreferencesStateX on NutritionPreferencesState {
  DietaryPreferences? get preferences => switch (this) {
    NutritionPreferencesLoaded(:final preferences) => preferences,
    NutritionPreferencesSavedState(:final preferences) => preferences,
    _ => null,
  };
}

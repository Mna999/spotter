import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';
import 'package:spotter/features/nutrition/domain/params/exclusion_params.dart';
import 'package:spotter/features/nutrition/domain/params/prefs_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/save_dietary_pref_params.dart';
import 'package:spotter/features/nutrition/domain/params/uid_params.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_dietary_preferences_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/save_dietary_preferences_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/update_exclusions_usecase.dart';

part 'nutrition_preferences_event.dart';
part 'nutrition_preferences_state.dart';

/// Owns the user's dietary preferences (macro targets, EGP budget and the
/// exclusion guardrails used by the meal planner).
class NutritionPreferencesBloc
    extends Bloc<NutritionPreferencesEvent, NutritionPreferencesState> {
  final GetDietaryPreferencesUseCase getPreferences;
  final SaveDietaryPreferencesUseCase savePreferences;
  final UpdateExclusionsUseCase updateExclusions;

  NutritionPreferencesBloc({
    required this.getPreferences,
    required this.savePreferences,
    required this.updateExclusions,
  }) : super(const NutritionPreferencesInitial()) {
    on<NutritionPreferencesRequested>(_onRequested);
    on<NutritionPreferencesSaved>(_onSaved);
    on<NutritionExclusionsUpdated>(_onExclusionsUpdated);
  }

  Future<void> _onRequested(
    NutritionPreferencesRequested event,
    Emitter<NutritionPreferencesState> emit,
  ) async {
    emit(const NutritionPreferencesLoading());
    final result = await getPreferences(PrefsIdParams(uid: event.uid,prefsId: event.prefsId));
    result.fold(
      (failure) => emit(NutritionPreferencesError(message: failure.message)),
      (prefs) => emit(NutritionPreferencesLoaded(preferences: prefs)),
    );
  }

  Future<void> _onSaved(
    NutritionPreferencesSaved event,
    Emitter<NutritionPreferencesState> emit,
  ) async {
    emit(const NutritionPreferencesLoading());
    final result = await savePreferences(
      SaveDietaryPrefParams(uid: event.uid, prefs: event.preferences),
    );
    result.fold(
      (failure) => emit(NutritionPreferencesError(message: failure.message)),
      (prefs) => emit(
        NutritionPreferencesSavedState(
          preferences: prefs,
          message: 'Dietary preferences saved.',
        ),
      ),
    );
  }

  Future<void> _onExclusionsUpdated(
    NutritionExclusionsUpdated event,
    Emitter<NutritionPreferencesState> emit,
  ) async {
    emit(const NutritionPreferencesLoading());
    final result = await updateExclusions(
      ExclusionParams(uid: event.uid, excludedFoodIds: event.excludedFoodIds),
    );
    result.fold(
      (failure) => emit(NutritionPreferencesError(message: failure.message)),
      (prefs) => emit(
        NutritionPreferencesSavedState(
          preferences: prefs,
          message: 'Dietary exclusions updated.',
        ),
      ),
    );
  }
}

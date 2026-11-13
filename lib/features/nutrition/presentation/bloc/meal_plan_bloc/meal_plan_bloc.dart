import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan_entries.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan_summary.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/params/add_meal_entry_params.dart';
import 'package:spotter/features/nutrition/domain/params/budget_params.dart';
import 'package:spotter/features/nutrition/domain/params/create_meal_plan_params.dart';
import 'package:spotter/features/nutrition/domain/params/exclusion_params.dart';
import 'package:spotter/features/nutrition/domain/params/list_meal_entries_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_entry_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_ids_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_totals_params.dart';
import 'package:spotter/features/nutrition/domain/params/prefs_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/save_plan_params.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_entry_params.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_plan_params.dart';
import 'package:spotter/features/nutrition/domain/usecases/add_meal_entry_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/build_meal_plan_totals_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/commit_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/create_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/delete_meal_entry_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/delete_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/generate_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_meal_plan_entries_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_meal_plans_summary_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/list_recent_meal_plans_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/regen_under_budget_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/save_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/update_exclusions_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/update_meal_entry_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/update_meal_plan_usecase.dart';
import 'package:spotter/features/workouts/domain/params/limit_params.dart';

part 'meal_plan_event.dart';
part 'meal_plan_state.dart';

class MealPlanBloc extends Bloc<MealPlanEvent, MealPlanState> {
  final CreateMealPlanUseCase createMealPlan;
  final GenerateMealPlanUseCase generateMealPlan;
  final RegenerateUnderBudgetUseCase regenerateUnderBudget;
  final SaveMealPlanUsecase saveMealPlan;
  final GetMealPlanUseCase getMealPlan;
  final UpdateMealPlanUseCase updateMealPlan;
  final DeleteMealPlanUseCase deleteMealPlan;
  final ListRecentMealPlansUsecase listRecentMealPlans;
  final AddMealEntryUseCase addMealEntry;
  final UpdateMealEntryUseCase updateMealEntry;
  final DeleteMealEntryUseCase deleteMealEntry;
  final GetMealPlanEntriesUseCase getMealPlanEntries;
  final GetMealPlansSummaryUseCase getMealPlansSummary;
  final BuildMealPlanTotalsUseCase buildMealPlanTotals;
  final CommitMealPlanUseCase commitMealPlan;
  final UpdateExclusionsUseCase updateExclusions;

  MealPlanBloc({
    required this.createMealPlan,
    required this.generateMealPlan,
    required this.regenerateUnderBudget,
    required this.saveMealPlan,
    required this.getMealPlan,
    required this.updateMealPlan,
    required this.deleteMealPlan,
    required this.listRecentMealPlans,
    required this.addMealEntry,
    required this.updateMealEntry,
    required this.deleteMealEntry,
    required this.getMealPlanEntries,
    required this.getMealPlansSummary,
    required this.buildMealPlanTotals,
    required this.commitMealPlan,
    required this.updateExclusions,
  }) : super(const MealPlanInitial()) {
    on<MealPlanCreated>(_onCreated);
    on<PlanGenerated>(_onGenerated);
    on<PlanRegeneratedUnderBudget>(_onRegenerated);
    on<PlanSaved>(_onSaved);
    on<PlanCommitted>(_onCommitted);
    on<PlanLoaded>(_onLoaded);
    on<PlanUpdated>(_onUpdated);
    on<PlanDeleted>(_onDeleted);
    on<MealPlanListRequested>(_onListRequested);
    on<MealEntriesRequested>(_onEntriesRequested);
    on<MealEntryAdded>(_onEntryAdded);
    on<MealEntryUpdated>(_onEntryUpdated);
    on<MealEntryRemoved>(_onEntryRemoved);
    on<UnloggedMealEntriesRemoved>(_onUnloggedEntriesRemoved);
    on<ExclusionsChanged>(_onExclusionsChanged);
  }

  Future<void> _onCreated(
    MealPlanCreated e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await createMealPlan(
      CreateMealPlanParams(
        uid: e.uid,
        date: e.date,
        budgetEgp: e.budgetEgp,
        name: e.name,
      ),
    );
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (p) => emit(
        MealPlanLoaded(mealPlan: p, message: 'Draft meal plan created.'),
      ),
    );
  }

  Future<void> _onGenerated(
    PlanGenerated e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await generateMealPlan(
      PrefsIdParams(uid: e.uid, prefsId: e.prefsId),
    );
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (p) => emit(MealPlanLoaded(mealPlan: p, message: 'Meal plan generated.')),
    );
  }

  Future<void> _onRegenerated(
    PlanRegeneratedUnderBudget e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await regenerateUnderBudget(
      BudgetParams(uid: e.uid, budgetEgp: e.budgetEgp, prefsId: e.prefsId),
    );
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (p) => emit(
        MealPlanLoaded(mealPlan: p, message: 'Plan regenerated under budget.'),
      ),
    );
  }

  Future<void> _onSaved(PlanSaved e, Emitter<MealPlanState> emit) async {
    emit(const MealPlanLoading());
    try {
      final r = await saveMealPlan(
        SavePlanParams(uid: e.uid, mealPlan: e.mealPlan),
      );
      r.fold(
        (f) => emit(MealPlanError(message: f.message)),
        (p) => emit(MealPlanSaved(mealPlan: p)),
      );
    } catch (_) {
      // Never leave the screen stuck on its saving spinner.
      emit(
        const MealPlanError(
          message: 'Could not save the meal plan. Please try again.',
        ),
      );
    }
  }

  Future<void> _onCommitted(
    PlanCommitted e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await commitMealPlan(
      MealPlanIdParams(uid: e.uid, mealPlanId: e.mealPlanId),
    );
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (p) => emit(MealPlanSaved(mealPlan: p)),
    );
  }

  Future<void> _onLoaded(PlanLoaded e, Emitter<MealPlanState> emit) async {
    emit(const MealPlanLoading());
    final r = await getMealPlan(
      MealPlanIdParams(uid: e.uid, mealPlanId: e.mealPlanId),
    );
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (p) => emit(MealPlanLoaded(mealPlan: p)),
    );
  }

  Future<void> _onUpdated(PlanUpdated e, Emitter<MealPlanState> emit) async {
    emit(const MealPlanLoading());
    final r = await updateMealPlan(e.params);
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (p) => emit(MealPlanLoaded(mealPlan: p, message: 'Meal plan updated.')),
    );
  }

  Future<void> _onDeleted(PlanDeleted e, Emitter<MealPlanState> emit) async {
    emit(const MealPlanLoading());
    final r = await deleteMealPlan(
      MealPlanIdParams(uid: e.uid, mealPlanId: e.mealPlanId),
    );
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (p) => emit(const MealPlanEmpty(message: 'Meal plan deleted.')),
    );
  }

  Future<void> _onListRequested(
    MealPlanListRequested e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await listRecentMealPlans(
      LimitParams(uid: e.uid, limit: e.limit, cursor: e.cursor),
    );
    final plans = r.fold<List<MealPlan>?>(
      (failure) {
        emit(MealPlanError(message: failure.message));
        return null;
      },
      (value) => value,
    );
    if (plans == null) return;
    if (plans.isEmpty) {
      emit(const MealPlanEmpty());
      return;
    }

    final summaryResult = await getMealPlansSummary(
      MealPlanIdsParams(
        uid: e.uid,
        mealPlanIds: plans.map((plan) => plan.mealPlanId).toList(),
      ),
    );
    final summary = summaryResult.fold(
      (_) => const MealPlanSummary(),
      (value) => value,
    );
    emit(MealPlanLoaded(plans: plans, summary: summary));
  }

  /// Loads the entries of one plan with their foods and aggregates.
  Future<void> _onEntriesRequested(
    MealEntriesRequested e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealEntriesLoading());
    final r = await getMealPlanEntries(
      ListMealEntriesParams(uid: e.uid, mealPlanId: e.mealPlanId),
    );
    r.fold(
      (f) => emit(MealEntriesError(message: f.message)),
      (data) => emit(MealEntriesLoaded(data: data)),
    );
  }

  Future<void> _onEntryAdded(
    MealEntryAdded e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await addMealEntry(e.params);
    MealEntry? added;
    String? error;
    r.fold((f) => error = f.message, (entry) => added = entry);
    final entry = added;
    if (entry == null) {
      emit(
        MealPlanError(message: error ?? 'Could not add the meal entry.'),
      );
      return;
    }

    // Keep the plan document's stored totals in sync with its entries so the
    // meal-plan list shows the updated price without a manual save.
    final plan = await _withFreshTotals(e.mealPlan, e.params.uid);
    emit(
      MealPlanLoaded(
        mealPlan: plan,
        entries: [entry],
        message: 'Meal entry added.',
      ),
    );
  }

  Future<void> _onEntryRemoved(
    MealEntryRemoved e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await deleteMealEntry(e.params);
    String? error;
    r.fold((f) => error = f.message, (_) {});
    if (error != null) {
      emit(MealPlanError(message: error!));
      return;
    }

    final plan = await _withFreshTotals(e.mealPlan, e.params.uid);
    final data = await _loadEntries(e.params.uid, e.params.mealPlanId);
    emit(
      MealPlanLoaded(
        mealPlan: plan,
        message: 'Food removed from meal plan.',
      ),
    );
    emit(MealEntriesLoaded(data: data));
  }

  Future<void> _onUnloggedEntriesRemoved(
    UnloggedMealEntriesRemoved e,
    Emitter<MealPlanState> emit,
  ) async {
    if (e.mealEntryIds.isEmpty) return;
    emit(const MealPlanLoading());

    for (final entryId in e.mealEntryIds) {
      final r = await deleteMealEntry(
        MealEntryIdParams(
          uid: e.uid,
          mealPlanId: e.mealPlanId,
          mealEntryId: entryId,
        ),
      );
      String? error;
      r.fold((f) => error = f.message, (_) {});
      if (error != null) {
        emit(MealPlanError(message: error!));
        return;
      }
    }

    final plan = await _withFreshTotals(e.mealPlan, e.uid);
    final data = await _loadEntries(e.uid, e.mealPlanId);
    emit(
      MealPlanLoaded(
        mealPlan: plan,
        message: 'Unlogged foods removed.',
      ),
    );
    emit(MealEntriesLoaded(data: data));
  }

  Future<MealPlanEntries> _loadEntries(String uid, String mealPlanId) async {
    final result = await getMealPlanEntries(
      ListMealEntriesParams(uid: uid, mealPlanId: mealPlanId),
    );
    return result.fold(
      (_) => const MealPlanEntries(),
      (value) => value,
    );
  }

  /// Recomputes [plan]'s kcal and EGP cost from its entries and persists them.
  Future<MealPlan?> _withFreshTotals(MealPlan? plan, String uid) async {
    if (plan == null) return null;
    final result = await buildMealPlanTotals(
      MealPlanTotalsParams(uid: uid, plan: plan),
    );
    return result.fold((_) => plan, (value) => value);
  }

  Future<void> _onEntryUpdated(
    MealEntryUpdated e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await updateMealEntry(e.params);
    String? error;
    r.fold((f) => error = f.message, (_) {});
    if (error != null) {
      emit(MealPlanError(message: error!));
      return;
    }

    final plan = await _withFreshTotals(e.mealPlan, e.params.uid);
    final data = await _loadEntries(e.params.uid, e.params.mealPlanId);
    emit(
      MealPlanLoaded(mealPlan: plan, message: 'Meal entry updated.'),
    );
    emit(MealEntriesLoaded(data: data));
  }

  Future<void> _onExclusionsChanged(
    ExclusionsChanged e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await updateExclusions(
      ExclusionParams(
        uid: e.uid,
        prefsId: e.prefsId ?? e.uid,
        excludedFoodIds: e.excludedFoodIds,
        excludedCategories: e.excludedCategories,
      ),
    );
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (_) => emit(
        MealPlanLoaded(
          mealPlan: e.mealPlan,
          message: 'Dietary exclusions updated.',
        ),
      ),
    );
  }
}

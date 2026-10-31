import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/params/add_meal_entry_params.dart';
import 'package:spotter/features/nutrition/domain/params/budget_params.dart';
import 'package:spotter/features/nutrition/domain/params/create_meal_plan_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/prefs_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/save_plan_params.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_plan_params.dart';
import 'package:spotter/features/nutrition/domain/usecases/add_meal_entry_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/create_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/delete_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/generate_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/list_recent_meal_plans_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/regen_under_budget_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/save_meal_plan_usecase.dart';
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
  }) : super(const MealPlanInitial()) {
    on<MealPlanCreated>(_onCreated);
    on<PlanGenerated>(_onGenerated);
    on<PlanRegeneratedUnderBudget>(_onRegenerated);
    on<PlanSaved>(_onSaved);
    on<PlanLoaded>(_onLoaded);
    on<PlanUpdated>(_onUpdated);
    on<PlanDeleted>(_onDeleted);
    on<MealPlanListRequested>(_onListRequested);
    on<MealEntryAdded>(_onEntryAdded);
    on<MealEntryUpdated>(_onEntryUpdated);
    on<MealEntryRemoved>(_onEntryRemoved);
    on<ExclusionsChanged>(_onExclusionsChanged);
  }

  Future<void> _onCreated(
    MealPlanCreated e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await createMealPlan(
      CreateMealPlanParams(uid: e.uid, date: e.date, budgetEgp: e.budgetEgp),
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
    final r = await saveMealPlan(
      SavePlanParams(uid: e.uid, mealPlan: e.mealPlan),
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
      (_) => emit(const MealPlanEmpty(message: 'Meal plan deleted.')),
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
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (plans) => emit(
        plans.isEmpty ? const MealPlanEmpty() : MealPlanLoaded(plans: plans),
      ),
    );
  }

  Future<void> _onEntryAdded(
    MealEntryAdded e,
    Emitter<MealPlanState> emit,
  ) async {
    emit(const MealPlanLoading());
    final r = await addMealEntry(e.params);
    r.fold(
      (f) => emit(MealPlanError(message: f.message)),
      (entry) => emit(
        MealPlanLoaded(
          mealPlan: e.mealPlan,
          entries: [entry],
          message: 'Meal entry added.',
        ),
      ),
    );
  }

  void _onEntryUpdated(MealEntryUpdated e, Emitter<MealPlanState> emit) => emit(
    const MealPlanError(
      message:
          'MealEntryUpdated is defined in the class diagram, but UpdateMealEntryUseCase is not present in this project yet.',
    ),
  );
  void _onEntryRemoved(MealEntryRemoved e, Emitter<MealPlanState> emit) => emit(
    const MealPlanError(
      message:
          'MealEntryRemoved is defined in the class diagram, but DeleteMealEntryUseCase is not present in this project yet.',
    ),
  );
  void _onExclusionsChanged(
    ExclusionsChanged e,
    Emitter<MealPlanState> emit,
  ) => emit(
    const MealPlanError(
      message:
          'ExclusionsChanged is defined in the class diagram, but the nutrition preferences update use case is not present in this project yet.',
    ),
  );
}

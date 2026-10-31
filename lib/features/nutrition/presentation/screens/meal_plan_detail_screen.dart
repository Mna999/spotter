import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/params/log_food_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';
import 'package:spotter/features/nutrition/presentation/bloc/food_log_bloc/food_log_bloc.dart';
import 'package:spotter/features/nutrition/presentation/bloc/meal_plan_bloc/meal_plan_bloc.dart';
import 'package:spotter/features/nutrition/presentation/bloc/nutrition_preferences_bloc/nutrition_preferences_bloc.dart';
import 'package:spotter/features/nutrition/presentation/screens/food_search_screen.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';
import 'package:spotter/features/nutrition/presentation/widgets/meal_entry_card.dart';
import 'package:spotter/features/nutrition/presentation/widgets/nutrition_message_view.dart';
import 'package:spotter/features/nutrition/presentation/widgets/nutrition_summary_card.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';
import 'package:spotter/injection_container.dart';

/// Detail of one meal plan: macro / budget summary, planned foods and actions
/// to save, regenerate or log an entry to today's diary.
class MealPlanDetailScreen extends StatefulWidget {
  const MealPlanDetailScreen({
    super.key,
    required this.uid,
    required this.plan,
  });

  final String uid;
  final MealPlan plan;

  @override
  State<MealPlanDetailScreen> createState() => _MealPlanDetailScreenState();
}

class _MealPlanDetailScreenState extends State<MealPlanDetailScreen> {
  final MealPlanBloc _bloc = sl<MealPlanBloc>();
  late MealPlan _plan = widget.plan;
  List<MealEntry> _entries = const [];
  Map<String, FoodItem> _foods = const {};
  bool _loadingEntries = true;
  bool _savingPlan = false;
  bool _regenerating = false;
  String? _entryError;
  String? _loggingEntryId;

  bool get _isDraft => _plan.mealPlanId.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadEntries();
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final planId = _plan.mealPlanId.trim();
    if (planId.isEmpty) {
      setState(() {
        _entries = const [];
        _foods = const {};
        _loadingEntries = false;
        _entryError = null;
      });
      return;
    }
    setState(() => _loadingEntries = true);
    final result = await sl<MealEntryRepo>().list(
      uid: widget.uid,
      mealPlanId: planId,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loadingEntries = false;
        _entryError = failure.message;
      }),
      (entries) {
        setState(() {
          _entries = entries;
          _loadingEntries = false;
          _entryError = null;
        });
        _loadFoods(entries);
      },
    );
  }

  Future<void> _loadFoods(List<MealEntry> entries) async {
    final missing = entries
        .map((entry) => entry.foodId)
        .where((id) => !_foods.containsKey(id))
        .toSet();
    if (missing.isEmpty) return;
    final foods = await fetchFoodsById(missing);
    if (!mounted) return;
    setState(() => _foods = {..._foods, ...foods});
  }

  void _onMealPlanState(MealPlanState state) {
    final cs = Theme.of(context).colorScheme;
    if (state is MealPlanLoaded) {
      if (_regenerating && state.mealPlan != null) {
        _regenerating = false;
        final draft = state.mealPlan!;
        if (state.message != null) {
          SnackBarBuilder.showSnackBar(context, state.message!, false, cs);
        }
        Routing.routeReplacement(
          MealPlanDetailScreen(uid: widget.uid, plan: draft),
          context,
        );
        return;
      }
      if (state.mealPlan != null) {
        setState(() => _plan = state.mealPlan!);
      }
      if (state.entries.isNotEmpty) {
        _loadEntries();
      }
      if (state.message != null) {
        SnackBarBuilder.showSnackBar(context, state.message!, false, cs);
      }
    } else if (state is MealPlanSaved) {
      setState(() {
        _plan = state.mealPlan;
        _savingPlan = false;
      });
      SnackBarBuilder.showSnackBar(
        context,
        _isDraft
            ? 'This plan still has no saved id. Please try saving again.'
            : 'Meal plan saved.',
        _isDraft,
        cs,
      );
    } else if (state is MealPlanEmpty) {
      _savingPlan = false;
      if (state.message != null) {
        SnackBarBuilder.showSnackBar(context, state.message!, false, cs);
        Navigator.pop(context);
      }
    } else if (state is MealPlanError) {
      setState(() {
        _savingPlan = false;
        _regenerating = false;
      });
      SnackBarBuilder.showSnackBar(context, state.message, true, cs);
    }
  }

  void _onFoodLogState(FoodLogState state) {
    if (_loggingEntryId == null) return;
    final cs = Theme.of(context).colorScheme;
    if (state is FoodLogError) {
      setState(() => _loggingEntryId = null);
      SnackBarBuilder.showSnackBar(context, state.message, true, cs);
    } else if (state is FoodLogLoaded) {
      setState(() => _loggingEntryId = null);
      SnackBarBuilder.showSnackBar(
        context,
        'Entry logged to today.',
        false,
        cs,
      );
    }
  }

  void _savePlan() {
    if (_savingPlan) return;
    setState(() => _savingPlan = true);
    _bloc.add(PlanSaved(uid: widget.uid, mealPlan: _plan));
  }

  void _deletePlan() {
    if (_isDraft) {
      SnackBarBuilder.showSnackBar(
        context,
        'This draft has not been saved yet.',
        true,
        Theme.of(context).colorScheme,
      );
      return;
    }
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete meal plan?'),
        content: Text(
          'Delete the plan for ${friendlyDate(_plan.date)} and all of its '
          'entries?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _bloc.add(
                PlanDeleted(
                  uid: widget.uid,
                  mealPlanId: _plan.mealPlanId,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _regenerate() async {
    final budget = await _askBudget(initial: _plan.budgetEgp);
    if (budget == null || !mounted) return;
    setState(() => _regenerating = true);
    _bloc.add(
      PlanRegeneratedUnderBudget(uid: widget.uid, budgetEgp: budget,prefsId: ''),
    );
  }

  Future<double?> _askBudget({double? initial}) async {
    final controller = TextEditingController(
      text: initial == null ? '' : initial.toStringAsFixed(0),
    );
    final result = await showAppDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Regenerate under budget'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Daily budget (EGP)',
            hintText: 'e.g. 150',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value <= 0) return;
              Navigator.pop(dialogContext, value);
            },
            child: const Text('REGENERATE'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _addFood() async {
    if (_isDraft) {
      SnackBarBuilder.showSnackBar(
        context,
        'Save the plan before adding foods to it.',
        true,
        Theme.of(context).colorScheme,
      );
      return;
    }
    await Routing.routePush(
      FoodSearchScreen(
        uid: widget.uid,
        mode: FoodActionMode.addToPlan,
        mealPlan: _plan,
      ),
      context,
    );
    if (!mounted) return;
    _loadEntries();
  }

  void _logEntry(MealEntry entry) {
    if (_loggingEntryId != null) return;
    setState(() => _loggingEntryId = entry.mealEntryId);
    context.read<FoodLogBloc>().add(
      FoodLogged(
        LogFoodParams(
          uid: widget.uid,
          foodId: entry.foodId,
          mealType: entry.mealType,
          portion: entry.portion,
          servingsCount: entry.servingsCount,
          loggetAt: DateTime.now(),
          note: entry.note,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final prefs = context.watch<NutritionPreferencesBloc>().state.preferences;
    final consumed = macrosForEntries(_entries, _foods);
    final spent = _plan.costEgp > 0
        ? _plan.costEgp
        : estimatedCostForEntries(_entries, _foods);
    final targetKcal = prefs?.targetKcal ??
        (_plan.totalKcal > 0 ? _plan.totalKcal : null);
    final budget = _plan.budgetEgp ?? prefs?.budgetEgp;

    return BlocProvider<MealPlanBloc>.value(
      value: _bloc,
      child: BlocListener<FoodLogBloc, FoodLogState>(
        listenWhen: (_, state) =>
            _loggingEntryId != null &&
            (state is FoodLogLoaded || state is FoodLogError),
        listener: (context, state) => _onFoodLogState(state),
        child: BlocConsumer<MealPlanBloc, MealPlanState>(
          listener: (context, state) => _onMealPlanState(state),
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Meal plan', style: text.headlineMedium),
                actions: [
                  IconButton(
                    onPressed: _deletePlan,
                    tooltip: 'Delete plan',
                    icon: const Icon(Icons.delete_outline),
                  ),
                  IconButton(
                    onPressed: _loadEntries,
                    tooltip: 'Refresh entries',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: _loadEntries,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _PlanHeader(
                      plan: _plan,
                      isDraft: _isDraft,
                      saving: _savingPlan,
                      onSave: _savePlan,
                    ),
                    const SizedBox(height: 12),
                    NutritionSummaryCard(
                      consumed: consumed,
                      targetKcal: targetKcal,
                      targetProteinG: prefs?.targetProteinG,
                      targetCarbsG: prefs?.targetCarbG,
                      targetFatG: prefs?.targetFatG,
                      budgetEgp: budget,
                      spentEgp: spent,
                      logCount: _entries.length,
                    ),
                    const SizedBox(height: 18),
                    SectionTitle(
                      title: 'PLANNED MEALS',
                      trailing: '${_entries.length} ITEMS',
                    ),
                    const SizedBox(height: 8),
                    if (_loadingEntries)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_entryError != null)
                      NutritionMessageView(
                        title: 'Could not load entries',
                        message: _entryError!,
                        icon: Icons.cloud_off_outlined,
                        isError: true,
                        onAction: _loadEntries,
                      )
                    else if (_entries.isEmpty)
                      NutritionMessageView(
                        title: 'No foods planned yet',
                        message: _isDraft
                            ? 'Save this draft, then add foods from the '
                                  'catalogue.'
                            : 'Add foods from the catalogue to build this '
                                  'day.',
                        icon: Icons.restaurant_menu,
                        onAction: _isDraft ? _savePlan : _addFood,
                        actionLabel: _isDraft ? 'SAVE PLAN' : 'ADD FOOD',
                      )
                    else
                      ..._entryGroups(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _addFood,
                        icon: const Icon(Icons.add),
                        label: const Text('ADD FOOD TO PLAN'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _regenerate,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('REGENERATE UNDER BUDGET'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isDraft)
                      Text(
                        'This plan is still a draft. Save it to give it an id '
                        'before adding entries.',
                        style: text.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _entryGroups() {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final groups = <MealType, List<MealEntry>>{};
    for (final entry in _entries) {
      groups.putIfAbsent(entry.mealType, () => []).add(entry);
    }
    final types = groups.keys.toList()
      ..sort((a, b) => mealTypeOrder(a).compareTo(mealTypeOrder(b)));

    final widgets = <Widget>[];
    for (final type in types) {
      final entries = groups[type]!..sort((a, b) => a.order.compareTo(b.order));
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Row(
            children: [
              Icon(mealTypeIcon(type), size: 17, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                mealTypeLabel(type).toUpperCase(),
                style: text.labelSmall!.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${entries.length} ${entries.length == 1 ? 'item' : 'items'}',
                style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
      for (final entry in entries) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MealEntryCard(
              entry: entry,
              food: _foods[entry.foodId],
              isLogging: _loggingEntryId == entry.mealEntryId,
              onLog: () => _logEntry(entry),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.plan,
    required this.isDraft,
    required this.saving,
    required this.onSave,
  });

  final MealPlan plan;
  final bool isDraft;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final statusColor = isDraft ? cs.secondary : cs.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  planStatusLabel(plan.status),
                  style: text.labelSmall!.copyWith(color: statusColor),
                ),
              ),
              const Spacer(),
              if (isDraft)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'UNSAVED DRAFT',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            friendlyDate(plan.date),
            style: text.headlineMedium!.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            'Daily Egyptian plan',
            style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('SAVE PLAN'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

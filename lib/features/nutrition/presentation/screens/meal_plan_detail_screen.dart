import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
import 'package:spotter/features/nutrition/domain/params/date_params.dart';
import 'package:spotter/features/nutrition/domain/params/log_food_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_entry_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_plan_params.dart';
import 'package:spotter/features/nutrition/domain/usecases/list_meal_logs_for_date_usecase.dart';
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
  String? _undoingEntryId;
  String? _deletingEntryId;

  TextEditingController nameController = TextEditingController();
  TextEditingController budgetController = TextEditingController();

  /// Today's logs created from a plan entry, keyed by the source entry id.
  /// Keeping the log lets the user undo a "LOG" action from this screen.
  final Map<String, MealLog?> _loggedByEntry = {};

  bool get _isDraft => _plan.mealPlanId.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPlan();
      _loadEntries();
      _loadLoggedEntries();
    });
  }

  /// Marks the plan entries that were already logged today. Persisting the
  /// entry id on the log lets us restore the "LOGGED" state after the screen
  /// is popped and opened again.
  Future<void> _loadLoggedEntries() async {
    final result = await sl<ListMealLogsForDateUseCase>()(
      DateParams(uid: widget.uid, date: dateOnly(DateTime.now())),
    );
    if (!mounted) return;
    result.fold((_) {}, (logs) {
      final logged = <String, MealLog?>{};
      for (final log in logs) {
        final entryId = log.sourceMealEntryId;
        if (entryId != null && entryId.isNotEmpty) logged[entryId] = log;
      }
      setState(() {
        _loggedByEntry
          ..clear()
          ..addAll(logged);
      });
    });
  }

  @override
  void dispose() {
    _bloc.close();
    nameController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  /// Asks the bloc for the latest version of this plan (saved plans only).
  void _loadPlan() {
    if (_isDraft) return;
    _bloc.add(PlanLoaded(uid: widget.uid, mealPlanId: _plan.mealPlanId));
  }

  /// Asks the bloc for this plan's entries. Result arrives through
  /// [_onMealPlanState] as MealEntriesLoading / Loaded / Error.
  void _loadEntries() {
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
    _bloc.add(MealEntriesRequested(uid: widget.uid, mealPlanId: planId));
  }

  Future<void> _refresh() async {
    _loadPlan();
    _loadEntries();
    if (_isDraft) return;
    try {
      await _bloc.stream
          .firstWhere((s) => s is MealEntriesLoaded || s is MealEntriesError)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Timeout or bloc closed: just stop the refresh indicator.
    }
  }

  void _onMealPlanState(MealPlanState state) {
    final cs = Theme.of(context).colorScheme;
    if (state is MealPlanLoaded ||
        state is MealPlanError ||
        state is MealEntriesLoaded ||
        state is MealEntriesError) {
      if (_deletingEntryId != null) {
        setState(() => _deletingEntryId = null);
      }
    }
    if (state is MealEntriesLoading) {
      if (!_loadingEntries) setState(() => _loadingEntries = true);
    } else if (state is MealEntriesLoaded) {
      setState(() {
        _entries = state.entries;
        _foods = state.foods;
        _loadingEntries = false;
        _entryError = null;
      });
    } else if (state is MealEntriesError) {
      setState(() {
        _loadingEntries = false;
        _entryError = state.message;
      });
    } else if (state is MealPlanLoaded) {
      // Regeneration finished: open the new draft.
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
      // Ignore states that carry nothing for this screen (e.g. list results).
      if (state.mealPlan == null && state.entries.isEmpty) return;

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
      final saved = state.mealPlan;
      final stillDraft = saved.mealPlanId.trim().isEmpty;
      setState(() {
        if (!stillDraft) _plan = saved;
        _savingPlan = false;
      });
      SnackBarBuilder.showSnackBar(
        context,
        stillDraft
            ? 'Could not save this plan. Please try again.'
            : 'Meal plan saved.',
        stillDraft,
        cs,
      );
      // Now that the plan has an id, load its entries.
      if (!stillDraft) _loadEntries();
    } else if (state is MealPlanEmpty) {
      if (_savingPlan) setState(() => _savingPlan = false);
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
    final loggingEntryId = _loggingEntryId;
    final undoingEntryId = _undoingEntryId;
    if (loggingEntryId == null && undoingEntryId == null) return;
    final cs = Theme.of(context).colorScheme;

    if (state is FoodLogError) {
      setState(() {
        _loggingEntryId = null;
        _undoingEntryId = null;
      });
      SnackBarBuilder.showSnackBar(context, state.message, true, cs);
      return;
    }

    final finished = state is FoodLogLoaded || state is FoodLogEmpty;
    if (!finished) return;

    if (loggingEntryId != null) {
      final log = state is FoodLogLoaded && state.logs.isNotEmpty
          ? state.logs.first
          : null;
      setState(() {
        _loggingEntryId = null;
        _loggedByEntry[loggingEntryId] = log;
      });
      SnackBarBuilder.showSnackBar(
        context,
        'Entry logged to today.',
        false,
        cs,
      );
    } else if (undoingEntryId != null) {
      setState(() {
        _undoingEntryId = null;
        _loggedByEntry.remove(undoingEntryId);
      });
      SnackBarBuilder.showSnackBar(
        context,
        'Logged meal removed. You can log it again.',
        false,
        cs,
      );
    }
  }

  void _savePlan() {
    if (_savingPlan) return;
    // Persist the totals of the current entries so the plan list and the
    // next visit show up-to-date numbers.
    final consumed = macrosForEntries(_entries, _foods);
    final estimatedCost = estimatedCostForEntries(_entries, _foods);
    final plan = copyMealPlan(
      _plan,
      totalKcal: consumed.energyKcal > 0
          ? consumed.energyKcal
          : _plan.totalKcal,
      costEgp: estimatedCost > 0 ? estimatedCost : _plan.costEgp,
      // Saving is an explicit commit: the plan stops being a draft.
      status: PlanStatus.committed,
    );
    setState(() => _savingPlan = true);
    _bloc.add(PlanSaved(uid: widget.uid, mealPlan: plan));
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
                PlanDeleted(uid: widget.uid, mealPlanId: _plan.mealPlanId),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _regenerate() async {
    if (_regenerating) return;
    final budget = await _askBudget(initial: _plan.budgetEgp);
    if (budget == null || !mounted) return;
    setState(() => _regenerating = true);
    _bloc.add(
      PlanRegeneratedUnderBudget(
        uid: widget.uid,
        budgetEgp: budget,
        prefsId: widget.uid,
      ),
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

  /// Deletes a single unlogged food entry from this meal plan.
  void _deleteEntry(MealEntry entry) {
    if (_isDraft) return;
    final food = _foods[entry.foodId];
    final foodName = food?.nameEn ?? 'this food';
    final mealName = mealTypeLabel(entry.mealType);
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete food from meal?'),
        content: Text('Remove $foodName from $mealName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!mounted) return;
              setState(() => _deletingEntryId = entry.mealEntryId);
              _bloc.add(
                MealEntryRemoved(
                  params: MealEntryIdParams(
                    uid: widget.uid,
                    mealPlanId: _plan.mealPlanId,
                    mealEntryId: entry.mealEntryId,
                  ),
                  mealPlan: _plan,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteUnloggedEntries(MealType type, List<MealEntry> unloggedEntries) {
    if (_isDraft || unloggedEntries.isEmpty) return;
    final label = mealTypeLabel(type);
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete unlogged foods?'),
        content: Text(
          'Remove all unlogged foods (${unloggedEntries.length}) from $label?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!mounted) return;
              _bloc.add(
                UnloggedMealEntriesRemoved(
                  uid: widget.uid,
                  mealPlanId: _plan.mealPlanId,
                  mealEntryIds: unloggedEntries
                      .map((e) => e.mealEntryId)
                      .toList(),
                  mealPlan: _plan,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Reverses a previous "LOG" on this plan entry by deleting the meal log
  /// that was created from it. Goes through FoodLogBloc so the diary on the
  /// dashboard stays in sync.
  void _undoEntry(MealEntry entry) {
    if (_undoingEntryId != null || _loggingEntryId != null) return;
    final log = _loggedByEntry[entry.mealEntryId];
    if (log == null) {
      // No log id available (e.g. it was removed on another screen): refresh
      // the mapping so the button state is accurate.
      _loadLoggedEntries();
      return;
    }
    setState(() => _undoingEntryId = entry.mealEntryId);
    context.read<FoodLogBloc>().add(
      MealLogDeleted(
        uid: widget.uid,
        mealLogId: log.mealLogId,
        date: dateOnly(log.loggedAt),
      ),
    );
  }

  /// Opens the edit sheet for the plan header (name, date and budget).
  Future<void> _editPlan() async {
    nameController.text = _plan.name;
    budgetController.text = _plan.budgetEgp == null || _plan.budgetEgp == 0
        ? ''
        : _plan.budgetEgp!.toStringAsFixed(0);
    if (_savingPlan) return;
    final input = await _showEditPlanDialog();
    if (input == null || !mounted) return;

    final updated = copyMealPlan(
      _plan,
      name: input.name,
      date: input.date,
      budgetEgp: input.budget ?? 0,
    );

    if (_isDraft) {
      setState(() => _plan = updated);
      SnackBarBuilder.showSnackBar(
        context,
        'Plan details updated.',
        false,
        Theme.of(context).colorScheme,
      );
      return;
    }

    _bloc.add(
      PlanUpdated(
        UpdateMealPlanParams(
          uid: widget.uid,
          mealPlanId: _plan.mealPlanId,
          name: input.name,
          date: input.date,
          budgetEgp: input.budget ?? 0,
        ),
      ),
    );
  }

  Future<_PlanEditInput?> _showEditPlanDialog() async {
    var date = _plan.date;

    final result = await showAppDialog<_PlanEditInput>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit meal plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Plan name',
                  hintText: 'e.g. High-protein day',
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text(friendlyDate(date)),
                subtitle: Text('${date.day}/${date.month}/${date.year}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => date = dateOnly(picked));
                  }
                },
              ),
              TextField(
                controller: budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Daily budget (EGP, optional)',
                  hintText: 'e.g. 180',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _PlanEditInput(
                  name: nameController.text.trim(),
                  date: date,
                  budget: double.tryParse(budgetController.text.trim()),
                ),
              ),
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  void _logEntry(MealEntry entry) {
    if (_loggingEntryId != null || _undoingEntryId != null) return;
    if (_loggedByEntry.containsKey(entry.mealEntryId)) return;
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
          sourceMealEntryId: entry.mealEntryId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final prefs = context.watch<NutritionPreferencesBloc>().state.preferences;
    final profileState = context.watch<ProfileBloc>().state;
    final metrics = profileState is ProfileLoaded
        ? profileState.bodyMetrics
        : null;
    final goals = metrics?.macroTargets;
    final consumed = macrosForEntries(_entries, _foods);
    final estimatedCost = estimatedCostForEntries(_entries, _foods);
    // Once entries exist they are the source of truth; a saved plan's stored
    // cost is only used while entries are still loading.
    final spent = _entries.isEmpty
        ? (_plan.costEgp > 0 ? _plan.costEgp : estimatedCost)
        : estimatedCost;
    final targetKcal =
        goals?.calories.toDouble() ??
        (_plan.totalKcal > 0 ? _plan.totalKcal : null);
    final budget = _plan.budgetEgp ?? prefs?.budgetEgp;

    return BlocProvider<MealPlanBloc>.value(
      value: _bloc,
      child: BlocListener<FoodLogBloc, FoodLogState>(
        listenWhen: (_, state) =>
            (_loggingEntryId != null || _undoingEntryId != null) &&
            (state is FoodLogLoaded ||
                state is FoodLogEmpty ||
                state is FoodLogError),
        listener: (context, state) => _onFoodLogState(state),
        child: BlocConsumer<MealPlanBloc, MealPlanState>(
          listener: (context, state) => _onMealPlanState(state),
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Meal plan', style: text.headlineMedium),
                actions: [
                  IconButton(
                    onPressed: _editPlan,
                    tooltip: 'Edit plan',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: _deletePlan,
                    tooltip: 'Delete plan',
                    icon: const Icon(Icons.delete_outline),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    tooltip: 'Refresh entries',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: _refresh,
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
                      targetProteinG: goals?.proteinG.toDouble(),
                      targetCarbsG: goals?.carbsG.toDouble(),
                      targetFatG: goals?.fatG.toDouble(),
                      budgetEgp: budget,
                      spentEgp: spent,
                      logCount: _entries.length,
                      countLabel: 'in this plan',
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
                        onPressed: _regenerating ? null : _regenerate,
                        icon: _regenerating
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
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
      final unloggedEntries = entries
          .where((e) => !_loggedByEntry.containsKey(e.mealEntryId))
          .toList();
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
              if (!_isDraft && unloggedEntries.isNotEmpty) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    size: 19,
                    color: cs.error.withValues(alpha: 0.85),
                  ),
                  tooltip: 'Delete unlogged foods in ${mealTypeLabel(type)}',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () =>
                      _deleteUnloggedEntries(type, unloggedEntries),
                ),
              ],
            ],
          ),
        ),
      );
      for (final entry in entries) {
        final isLogged = _loggedByEntry.containsKey(entry.mealEntryId);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MealEntryCard(
              entry: entry,
              food: _foods[entry.foodId],
              isLogging: _loggingEntryId == entry.mealEntryId,
              isLogged: isLogged,
              isUndoing: _undoingEntryId == entry.mealEntryId,
              isDeleting: _deletingEntryId == entry.mealEntryId,
              onLog: () => _logEntry(entry),
              onUndo: () => _undoEntry(entry),
              onDelete: !_isDraft && !isLogged
                  ? () => _deleteEntry(entry)
                  : null,
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

class _PlanEditInput {
  const _PlanEditInput({required this.name, required this.date, this.budget});

  final String name;
  final DateTime date;
  final double? budget;
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            plan.name.trim().isNotEmpty
                ? plan.name.trim()
                : friendlyDate(plan.date),
            style: text.headlineMedium!.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            plan.name.trim().isNotEmpty
                ? '${friendlyDate(plan.date)} · Daily Egyptian plan'
                : 'Daily Egyptian plan',
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

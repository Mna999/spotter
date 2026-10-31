import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_log_params.dart';
import 'package:spotter/features/nutrition/presentation/bloc/food_log_bloc/food_log_bloc.dart';
import 'package:spotter/features/nutrition/presentation/bloc/nutrition_preferences_bloc/nutrition_preferences_bloc.dart';
import 'package:spotter/features/nutrition/presentation/screens/dietary_exclusions_screen.dart';
import 'package:spotter/features/nutrition/presentation/screens/food_search_screen.dart';
import 'package:spotter/features/nutrition/presentation/screens/meal_log_edit_sheet.dart';
import 'package:spotter/features/nutrition/presentation/screens/meal_plans_screen.dart';
import 'package:spotter/features/nutrition/presentation/screens/metabolic_targets_screen.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';
import 'package:spotter/features/nutrition/presentation/widgets/meal_log_card.dart';
import 'package:spotter/features/nutrition/presentation/widgets/nutrition_quick_action.dart';
import 'package:spotter/features/nutrition/presentation/widgets/nutrition_summary_card.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';

/// The nutrition tab: daily diary, macro/budget summary and entry points to
/// the food catalogue, meal plans and dietary preferences.
class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  State<NutritionDashboardScreen> createState() =>
      _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
  String? _uid;
  DateTime _date = dateOnly(DateTime.now());
  List<MealLog> _logs = const [];
  MacroNutrients _totals = MacroNutrients.zero;
  Map<String, FoodItem> _foods = const {};
  bool _terminal = false;
  bool _reloadAfterMutation = false;

  bool get _isToday => isSameDay(_date, DateTime.now());

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) _uid = authState.userAccount.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadLogs();
      _loadPreferences();
    });
  }

  void _loadLogs() {
    final uid = _uid;
    if (uid == null) return;
    context.read<FoodLogBloc>().add(
      LogsForDateRequested(uid: uid, date: _date),
    );
  }

  void _loadPreferences() {
    final uid = _uid;
    if (uid == null) return;
    context.read<NutritionPreferencesBloc>().add(
      NutritionPreferencesRequested(uid: uid, prefsId: ''),
    );
  }

  Future<void> _loadFoods(List<MealLog> logs) async {
    final missing = logs
        .map((log) => log.foodId)
        .where((id) => !_foods.containsKey(id))
        .toSet();
    if (missing.isEmpty) return;
    final foods = await fetchFoodsById(missing);
    if (!mounted) return;
    setState(() => _foods = {..._foods, ...foods});
  }

  void _onFoodLogState(FoodLogState state) {
    if (state is FoodLogLoaded) {
      setState(() {
        _logs = state.logs;
        _totals = state.totals;
        _terminal = true;
      });
      _loadFoods(state.logs);
      if (_reloadAfterMutation) {
        _reloadAfterMutation = false;
        _loadLogs();
      }
      if (state.message != null && mounted) {
        SnackBarBuilder.showSnackBar(
          context,
          state.message!,
          false,
          Theme.of(context).colorScheme,
        );
      }
    } else if (state is FoodLogEmpty) {
      setState(() {
        _logs = const [];
        _totals = state.totals ?? MacroNutrients.zero;
        _foods = const {};
        _terminal = true;
      });
      if (_reloadAfterMutation) {
        _reloadAfterMutation = false;
        _loadLogs();
      }
    } else if (state is FoodLogError) {
      setState(() {
        _terminal = true;
        _reloadAfterMutation = false;
      });
      SnackBarBuilder.showSnackBar(
        context,
        state.message,
        true,
        Theme.of(context).colorScheme,
      );
    }
  }

  void _changeDate(int days) {
    final next = _date.add(Duration(days: days));
    if (next.isAfter(dateOnly(DateTime.now()))) return;
    setState(() {
      _date = next;
      _logs = const [];
      _totals = MacroNutrients.zero;
      _foods = const {};
      _terminal = false;
    });
    _loadLogs();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: dateOnly(DateTime.now()),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = dateOnly(picked);
      _logs = const [];
      _totals = MacroNutrients.zero;
      _foods = const {};
      _terminal = false;
    });
    _loadLogs();
  }

  Future<void> _editLog(MealLog log) async {
    final uid = _uid;
    if (uid == null) return;
    final params = await showMealLogEditSheet(
      context,
      uid: uid,
      log: log,
      food: _foods[log.foodId],
    );
    if (params == null || !mounted) return;
    _updateLog(params);
  }

  void _updateLog(UpdateMealLogParams params) {
    _reloadAfterMutation = true;
    context.read<FoodLogBloc>().add(MealLogUpdated(params));
  }

  void _deleteLog(MealLog log) {
    final uid = _uid;
    if (uid == null) return;
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: Text(
          'Remove the ${log.mealType.name} entry from '
          '${friendlyDate(log.loggedAt)}?',
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
              _reloadAfterMutation = true;
              context.read<FoodLogBloc>().add(
                MealLogDeleted(uid: uid, mealLogId: log.mealLogId, date: _date),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _repeatYesterday() {
    final uid = _uid;
    if (uid == null) return;
    _reloadAfterMutation = true;
    context.read<FoodLogBloc>().add(YesterdayRepeated(uid: uid));
  }

  Future<void> _openSearch() async {
    final uid = _uid;
    if (uid == null) return;
    await Routing.routePush(
      FoodSearchScreen(
        uid: uid,
        logDate: _date,
        spentEgp: estimatedCostForLogs(_logs, _foods),
      ),
      context,
    );
    if (!mounted) return;
    _loadLogs();
    _loadPreferences();
  }

  Future<void> _openMealPlans() async {
    final uid = _uid;
    if (uid == null) return;
    await Routing.routePush(MealPlansScreen(uid: uid), context);
    if (!mounted) return;
    _loadLogs();
    _loadPreferences();
  }

  Future<void> _openExclusions() async {
    final uid = _uid;
    if (uid == null) return;
    await Routing.routePush(DietaryExclusionsScreen(uid: uid), context);
    if (!mounted) return;
    _loadPreferences();
  }

  Future<void> _openTargets() async {
    final uid = _uid;
    if (uid == null) return;
    await Routing.routePush(MetabolicTargetsScreen(uid: uid), context);
    if (!mounted) return;
    _loadPreferences();
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
    final targetKcal =
        prefs?.targetKcal ?? metrics?.macroTargets.calories.toDouble();
    final targetProtein =
        prefs?.targetProteinG ?? metrics?.macroTargets.proteinG.toDouble();
    final targetCarbs =
        prefs?.targetCarbG ?? metrics?.macroTargets.carbsG.toDouble();
    final targetFat =
        prefs?.targetFatG ?? metrics?.macroTargets.fatG.toDouble();
    final consumed = _logs.isEmpty ? _totals : macrosForLogs(_logs, _foods);
    final spent = estimatedCostForLogs(_logs, _foods);

    return BlocConsumer<FoodLogBloc, FoodLogState>(
      listener: (context, state) => _onFoodLogState(state),
      builder: (context, state) {
        if (!_terminal && (state is FoodLogLoading || state is FoodLogEmpty)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Nutrition', style: text.headlineMedium),
            actions: [
              IconButton(
                onPressed: () {
                  _loadLogs();
                  _loadPreferences();
                },
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                onPressed: _openTargets,
                tooltip: 'Macro targets',
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              _loadLogs();
              _loadPreferences();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _DateBar(
                  date: _date,
                  isToday: _isToday,
                  onPrevious: () => _changeDate(-1),
                  onNext: _isToday ? null : () => _changeDate(1),
                  onPick: _pickDate,
                ),
                const SizedBox(height: 12),
                NutritionSummaryCard(
                  consumed: consumed,
                  targetKcal: targetKcal,
                  targetProteinG: targetProtein,
                  targetCarbsG: targetCarbs,
                  targetFatG: targetFat,
                  budgetEgp: prefs?.budgetEgp,
                  spentEgp: spent,
                  logCount: _logs.length,
                ),
                const SizedBox(height: 18),
                const SectionTitle(title: 'QUICK ACTIONS'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: NutritionQuickAction(
                        icon: Icons.search,
                        title: 'Food database',
                        subtitle: 'Search Egyptian foods and log a portion.',
                        onTap: _openSearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NutritionQuickAction(
                        icon: Icons.event_note_outlined,
                        title: 'Meal plans',
                        subtitle: 'Build or generate a plan for the day.',
                        onTap: _openMealPlans,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: NutritionQuickAction(
                        icon: Icons.block_outlined,
                        title: 'Exclusions',
                        subtitle: 'Guardrails for foods you avoid.',
                        onTap: _openExclusions,
                        accent: cs.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NutritionQuickAction(
                        icon: Icons.speed_outlined,
                        title: 'Macro targets',
                        subtitle: 'Calories, macros and daily EGP budget.',
                        onTap: _openTargets,
                        accent: cs.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SectionTitle(
                  title: 'MEALS',
                  trailing: '${_logs.length} LOGGED',
                ),
                const SizedBox(height: 8),
                if (_logs.isEmpty)
                  _EmptyMeals(onSearch: _openSearch)
                else
                  ..._mealGroups(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openSearch,
                    icon: const Icon(Icons.add),
                    label: const Text('ADD FOOD'),
                  ),
                ),
                if (_isToday) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _repeatYesterday,
                      icon: const Icon(Icons.replay),
                      label: const Text('REPEAT YESTERDAY'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _mealGroups() {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final groups = <MealType, List<MealLog>>{};
    for (final log in _logs) {
      groups.putIfAbsent(log.mealType, () => []).add(log);
    }
    final types = groups.keys.toList()
      ..sort((a, b) => mealTypeOrder(a).compareTo(mealTypeOrder(b)));

    final widgets = <Widget>[];
    for (final type in types) {
      final logs = groups[type]!;
      final kcal = logs.fold<double>(
        0,
        (sum, log) =>
            sum +
            (_foods[log.foodId] == null
                ? log.computedKcal
                : kcalFor(_foods[log.foodId]!, log.grams)),
      );
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
                '${kcal.round()} kcal',
                style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
      for (final log in logs) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MealLogCard(
              log: log,
              food: _foods[log.foodId],
              onEdit: () => _editLog(log),
              onDelete: () => _deleteLog(log),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

class _DateBar extends StatelessWidget {
  const _DateBar({
    required this.date,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
  });

  final DateTime date;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: 'Previous day',
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onPick,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          friendlyDate(date),
                          style: text.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'PAST',
                              style: text.labelSmall!.copyWith(
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      DateFormatter.weekday(date),
                      style: text.bodySmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: 'Next day',
            icon: const Icon(Icons.chevron_right),
          ),
          IconButton(
            onPressed: onPick,
            tooltip: 'Pick a date',
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
    );
  }
}

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.restaurant_menu, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nothing logged yet', style: text.titleLarge),
                const SizedBox(height: 2),
                Text(
                  'Search the catalogue and add your first Egyptian meal.',
                  style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onSearch,
            tooltip: 'Search foods',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

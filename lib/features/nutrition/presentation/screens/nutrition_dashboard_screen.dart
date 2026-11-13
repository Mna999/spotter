import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/food_log_day.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
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
      NutritionPreferencesRequested(uid: uid, prefsId: uid),
    );
  }

  void _onFoodLogState(FoodLogState state) {
    final message = switch (state) {
      FoodLogLoaded(:final message) => message,
      FoodLogError(:final message) => message,
      _ => null,
    };
    if (message == null || !mounted) return;
    SnackBarBuilder.showSnackBar(
      context,
      message,
      state is FoodLogError,
      Theme.of(context).colorScheme,
    );
  }

  void _changeDate(int days) {
    final next = _date.add(Duration(days: days));
    if (next.isAfter(dateOnly(DateTime.now()))) return;
    setState(() => _date = next);
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
    setState(() => _date = dateOnly(picked));
    _loadLogs();
  }

  Future<void> _editLog(MealLog log, FoodItem? food) async {
    final uid = _uid;
    if (uid == null) return;
    final params = await showMealLogEditSheet(
      context,
      uid: uid,
      log: log,
      food: food,
    );
    if (params == null || !mounted) return;
    _updateLog(params);
  }

  void _updateLog(UpdateMealLogParams params) {
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
    context.read<FoodLogBloc>().add(YesterdayRepeated(uid: uid));
  }

  Future<void> _openSearch(FoodLogDay? day) async {
    final uid = _uid;
    if (uid == null) return;
    await Routing.routePush(
      FoodSearchScreen(
        uid: uid,
        logDate: _date,
        spentEgp: day?.spentEgp ?? 0,
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
    // Macro goals come from the user's profile (ProfileBloc), not from the
    // dietary preferences document.
    final goals = metrics?.macroTargets;

    return BlocConsumer<FoodLogBloc, FoodLogState>(
      listener: (context, state) => _onFoodLogState(state),
      builder: (context, state) {
        final day = switch (state) {
          FoodLogLoaded(:final day) => day,
          FoodLogEmpty(:final day) => day,
          _ => null,
        };
        if (day == null && state is! FoodLogError) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final logs = day?.logs ?? const <MealLog>[];
        final consumed = day?.totals ?? MacroNutrients.zero;

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
                  targetKcal: goals?.calories.toDouble(),
                  targetProteinG: goals?.proteinG.toDouble(),
                  targetCarbsG: goals?.carbsG.toDouble(),
                  targetFatG: goals?.fatG.toDouble(),
                  budgetEgp: prefs?.budgetEgp,
                  spentEgp: day?.spentEgp ?? 0,
                  logCount: logs.length,
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
                        onTap: () => _openSearch(day),
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
                        subtitle: 'Profile-based goals and daily EGP budget.',
                        onTap: _openTargets,
                        accent: cs.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SectionTitle(
                  title: 'MEALS',
                  trailing: '${logs.length} LOGGED',
                ),
                const SizedBox(height: 8),
                if (logs.isEmpty)
                  _EmptyMeals(onSearch: () => _openSearch(day))
                else
                  ..._mealGroups(day!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openSearch(day),
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

  List<Widget> _mealGroups(FoodLogDay day) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final widgets = <Widget>[];
    for (final group in day.mealGroups) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Row(
            children: [
              Icon(mealTypeIcon(group.mealType), size: 17, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                mealTypeLabel(group.mealType).toUpperCase(),
                style: text.labelSmall!.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${group.kcal.round()} kcal',
                style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
      for (final log in group.logs) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MealLogCard(
              log: log,
              food: day.foods[log.foodId],
              onEdit: () => _editLog(log, day.foods[log.foodId]),
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

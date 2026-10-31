import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/presentation/bloc/meal_plan_bloc/meal_plan_bloc.dart';
import 'package:spotter/features/nutrition/presentation/bloc/nutrition_preferences_bloc/nutrition_preferences_bloc.dart';
import 'package:spotter/features/nutrition/presentation/screens/meal_plan_detail_screen.dart';
import 'package:spotter/features/nutrition/presentation/screens/metabolic_targets_screen.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';
import 'package:spotter/features/nutrition/presentation/widgets/meal_plan_card.dart';
import 'package:spotter/features/nutrition/presentation/widgets/nutrition_message_view.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';
import 'package:spotter/injection_container.dart';

/// Lists the user's recent meal plans and creates / generates new ones.
class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key, required this.uid});

  final String uid;

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  final MealPlanBloc _bloc = sl<MealPlanBloc>();
  List<MealPlan> _plans = const [];
  bool _awaitingPlan = false;
  String? _deletingPlanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _load() {
    _bloc.add(MealPlanListRequested(uid: widget.uid));
  }

  void _onState(BuildContext context, MealPlanState state) {
    final cs = Theme.of(context).colorScheme;
    if (state is MealPlanLoaded) {
      if (state.plans.isNotEmpty) {
        setState(() => _plans = state.plans);
      }
      if (_awaitingPlan) {
        _awaitingPlan = false;
        final plan = state.mealPlan;
        if (plan != null) {
          _openDetail(plan);
        } else {
          SnackBarBuilder.showSnackBar(
            context,
            'Could not build a plan yet. Set your macro targets and budget '
            'first, then try again.',
            true,
            cs,
          );
        }
      }
      if (state.message != null) {
        SnackBarBuilder.showSnackBar(context, state.message!, false, cs);
      }
    } else if (state is MealPlanEmpty) {
      final deleting = _deletingPlanId;
      if (deleting != null) {
        setState(() {
          _plans = _plans
              .where((plan) => plan.mealPlanId != deleting)
              .toList();
          _deletingPlanId = null;
        });
        _load();
      } else if (!_awaitingPlan) {
        setState(() => _plans = const []);
      }
      _awaitingPlan = false;
      if (state.message != null) {
        SnackBarBuilder.showSnackBar(context, state.message!, false, cs);
      }
    } else if (state is MealPlanError) {
      _awaitingPlan = false;
      _deletingPlanId = null;
      SnackBarBuilder.showSnackBar(context, state.message, true, cs);
    }
  }

  Future<void> _openDetail(MealPlan plan) async {
    await Routing.routePush(
      MealPlanDetailScreen(uid: widget.uid, plan: plan),
      context,
    );
    if (!mounted) return;
    _load();
  }

  Future<void> _createPlan() async {
    final prefs = context
        .read<NutritionPreferencesBloc>()
        .state
        .preferences;
    final input = await _showCreatePlanDialog(
      defaultBudget: prefs?.budgetEgp,
    );
    if (input == null || !mounted) return;
    setState(() => _awaitingPlan = true);
    _bloc.add(
      MealPlanCreated(
        uid: widget.uid,
        date: input.date,
        budgetEgp: input.budget,
      ),
    );
  }

  void _generatePlan() {
    setState(() => _awaitingPlan = true);
    _bloc.add(PlanGenerated(uid: widget.uid,prefsId: ''));
  }

  Future<void> _openTargets() async {
    await Routing.routePush(
      MetabolicTargetsScreen(uid: widget.uid),
      context,
    );
  }

  void _deletePlan(MealPlan plan) {
    if (plan.mealPlanId.trim().isEmpty) {
      SnackBarBuilder.showSnackBar(
        context,
        'This draft has not been saved yet, so there is nothing to delete.',
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
          'Delete the plan for ${friendlyDate(plan.date)} and all of its '
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
              if (!mounted) return;
              setState(() => _deletingPlanId = plan.mealPlanId);
              _bloc.add(
                PlanDeleted(
                  uid: widget.uid,
                  mealPlanId: plan.mealPlanId,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<_PlanDraft?> _showCreatePlanDialog({double? defaultBudget}) async {
    var date = dateOnly(DateTime.now());
    final budgetController = TextEditingController(
      text: defaultBudget == null ? '' : defaultBudget.toStringAsFixed(0),
    );
    final result = await showAppDialog<_PlanDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New meal plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text(friendlyDate(date)),
                subtitle: Text(
                  '${date.day}/${date.month}/${date.year}',
                ),
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
              onPressed: () {
                final budget = double.tryParse(
                  budgetController.text.trim(),
                );
                Navigator.pop(
                  dialogContext,
                  _PlanDraft(date: date, budget: budget),
                );
              },
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
    budgetController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final prefs = context.watch<NutritionPreferencesBloc>().state.preferences;

    return BlocProvider<MealPlanBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Meal plans', style: text.headlineMedium),
          actions: [
            IconButton(
              onPressed: _load,
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'draft') _createPlan();
                if (value == 'generate') _generatePlan();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'draft',
                  child: Text('New empty plan'),
                ),
                PopupMenuItem(
                  value: 'generate',
                  child: Text('Generate from preferences'),
                ),
              ],
            ),
          ],
        ),
        body: BlocConsumer<MealPlanBloc, MealPlanState>(
          listener: _onState,
          builder: (context, state) {
            if (state is MealPlanLoading && _plans.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MealPlanError && _plans.isEmpty) {
              return NutritionMessageView(
                title: 'Could not load meal plans',
                message: state.message,
                icon: Icons.cloud_off_outlined,
                isError: true,
                onAction: _load,
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _PreferencesBanner(
                    targetKcal: prefs?.targetKcal,
                    budgetEgp: prefs?.budgetEgp,
                    onOpenTargets: _openTargets,
                  ),
                  const SizedBox(height: 18),
                  SectionTitle(
                    title: 'RECENT PLANS',
                    trailing: '${_plans.length}',
                  ),
                  const SizedBox(height: 8),
                  if (_plans.isEmpty)
                    NutritionMessageView(
                      title: 'No meal plans yet',
                      message: 'Create an empty plan or generate one from your '
                          'macro targets and EGP budget.',
                      icon: Icons.event_note_outlined,
                      onAction: _generatePlan,
                      actionLabel: 'GENERATE PLAN',
                    )
                  else
                    for (final plan in _plans)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MealPlanCard(
                          plan: plan,
                          onTap: () => _openDetail(plan),
                          onDelete: () => _deletePlan(plan),
                        ),
                      ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _generatePlan,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('GENERATE PLAN'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _createPlan,
                      icon: const Icon(Icons.add),
                      label: const Text('NEW EMPTY PLAN'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (prefs == null)
                    Text(
                      'Tip: set your macro targets and budget first so '
                      'generated plans match your goals.',
                      style: text.bodySmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlanDraft {
  const _PlanDraft({required this.date, this.budget});

  final DateTime date;
  final double? budget;
}

class _PreferencesBanner extends StatelessWidget {
  const _PreferencesBanner({
    required this.targetKcal,
    required this.budgetEgp,
    required this.onOpenTargets,
  });

  final double? targetKcal;
  final double? budgetEgp;
  final VoidCallback onOpenTargets;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final hasTarget = targetKcal != null && targetKcal! > 0;
    final hasBudget = budgetEgp != null && budgetEgp! > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.55),
            cs.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'EGYPTIAN MEAL PLANNER',
                  style: text.labelSmall!.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenTargets,
                child: const Text('TARGETS'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Plan your day around local food and an EGP budget.',
            style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _BannerPill(
                icon: Icons.local_fire_department_outlined,
                label: hasTarget
                    ? '${targetKcal!.round()} kcal target'
                    : 'No calorie target',
              ),
              _BannerPill(
                icon: Icons.account_balance_wallet_outlined,
                label: hasBudget
                    ? '${budgetEgp!.toStringAsFixed(0)} EGP / day'
                    : 'No daily budget',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerPill extends StatelessWidget {
  const _BannerPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.primary),
          const SizedBox(width: 4),
          Text(label, style: text.labelSmall!.copyWith(color: cs.onSurface)),
        ],
      ),
    );
  }
}

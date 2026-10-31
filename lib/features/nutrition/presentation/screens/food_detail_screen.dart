import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/core/theme/app_theme.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/params/add_meal_entry_params.dart';
import 'package:spotter/features/nutrition/domain/params/log_food_params.dart';
import 'package:spotter/features/nutrition/presentation/bloc/food_log_bloc/food_log_bloc.dart';
import 'package:spotter/features/nutrition/presentation/bloc/meal_plan_bloc/meal_plan_bloc.dart';
import 'package:spotter/features/nutrition/presentation/bloc/nutrition_preferences_bloc/nutrition_preferences_bloc.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';
import 'package:spotter/features/nutrition/presentation/widgets/budget_impact_card.dart';
import 'package:spotter/features/nutrition/presentation/widgets/macro_stat_card.dart';
import 'package:spotter/features/nutrition/presentation/widgets/meal_type_selector.dart';
import 'package:spotter/features/nutrition/presentation/widgets/portion_selector.dart';
import 'package:spotter/injection_container.dart';

/// Food detail + portion picker. Logs the food to the diary or adds it to an
/// existing meal plan, depending on [mode].
class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.uid,
    required this.food,
    this.mode = FoodActionMode.log,
    this.mealPlan,
    this.logDate,
    this.spentEgp,
  });

  final String uid;
  final FoodItem food;
  final FoodActionMode mode;
  final MealPlan? mealPlan;

  /// The day the food is logged to. Defaults to today.
  final DateTime? logDate;

  /// Amount already spent today, used by the budget impact card.
  final double? spentEgp;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late Portion _portion = defaultPortionFor(widget.food);
  double _servings = 1;
  late MealType _mealType = _defaultMealType();
  final TextEditingController _noteController = TextEditingController();
  final MealPlanBloc _planBloc = sl<MealPlanBloc>();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    _planBloc.close();
    super.dispose();
  }

  MealType _defaultMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 16) return MealType.lunch;
    if (hour < 21) return MealType.dinner;
    return MealType.snack;
  }

  DateTime get _loggedAt {
    final now = DateTime.now();
    final day = widget.logDate ?? now;
    return DateTime(
      day.year,
      day.month,
      day.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  void _submit() {
    if (_submitting) return;
    final note = _noteController.text.trim();
    final cs = Theme.of(context).colorScheme;

    if (widget.mode == FoodActionMode.addToPlan) {
      final plan = widget.mealPlan;
      if (plan == null || plan.mealPlanId.trim().isEmpty) {
        SnackBarBuilder.showSnackBar(
          context,
          'Save this meal plan before adding foods to it.',
          true,
          cs,
        );
        return;
      }
      setState(() => _submitting = true);
      _planBloc.add(
        MealEntryAdded(
          params: AddMealEntryParams(
            uid: widget.uid,
            mealPlanId: plan.mealPlanId,
            foodId: widget.food.foodId,
            mealType: _mealType,
            order: 0,
            portion: _portion,
            servingsCount: _servings,
            note: note.isEmpty ? null : note,
          ),
          mealPlan: plan,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    context.read<FoodLogBloc>().add(
      FoodLogged(
        LogFoodParams(
          uid: widget.uid,
          foodId: widget.food.foodId,
          mealType: _mealType,
          portion: _portion,
          servingsCount: _servings,
          loggetAt: _loggedAt,
          note: note.isEmpty ? null : note,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final food = widget.food;
    final grams = gramsFor(_portion, _servings);
    final macros = macrosFor(food, grams);
    final price = estimatedPrice(food, grams, _servings);
    final prefs = context.watch<NutritionPreferencesBloc>().state.preferences;
    final budget = prefs?.budgetEgp;
    final spent = widget.spentEgp ?? widget.mealPlan?.costEgp ?? 0.0;

    return BlocProvider<MealPlanBloc>.value(
      value: _planBloc,
      child: MultiBlocListener(
        listeners: [
        BlocListener<FoodLogBloc, FoodLogState>(
          listenWhen: (_, state) =>
              _submitting &&
              (state is FoodLogLoaded || state is FoodLogError),
          listener: (context, state) {
            if (state is FoodLogError) {
              setState(() => _submitting = false);
              SnackBarBuilder.showSnackBar(context, state.message, true, cs);
              return;
            }
            setState(() => _submitting = false);
            SnackBarBuilder.showSnackBar(
              context,
              '${food.nameEn} added to your log.',
              false,
              cs,
            );
            Navigator.pop(context, true);
          },
        ),
        BlocListener<MealPlanBloc, MealPlanState>(
          listenWhen: (_, state) =>
              _submitting &&
              (state is MealPlanLoaded || state is MealPlanError),
          listener: (context, state) {
            if (state is MealPlanError) {
              setState(() => _submitting = false);
              SnackBarBuilder.showSnackBar(context, state.message, true, cs);
              return;
            }
            if (state is MealPlanLoaded && state.entries.isNotEmpty) {
              setState(() => _submitting = false);
              SnackBarBuilder.showSnackBar(
                context,
                '${food.nameEn} added to the meal plan.',
                false,
                cs,
              );
              Navigator.pop(context, true);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Food details', style: text.headlineMedium),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.mode == FoodActionMode.addToPlan) ...[
              _PlanBanner(plan: widget.mealPlan),
              const SizedBox(height: 12),
            ],
            _FoodHero(
              food: food,
              grams: grams,
              price: price,
            ),
            const SizedBox(height: 16),
            PortionSelector(
              food: food,
              portion: _portion,
              servings: _servings,
              onPortionChanged: (portion) =>
                  setState(() => _portion = portion),
              onServingsChanged: (value) =>
                  setState(() => _servings = value),
            ),
            const SizedBox(height: 16),
            Text(
              'MEAL',
              style: text.labelSmall!.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            MealTypeSelector(
              selected: _mealType,
              onChanged: (type) => setState(() => _mealType = type),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MacroStatCard(
                    label: 'Protein',
                    arabicLabel: 'بروتين',
                    value: macros.proteinG,
                    icon: Icons.fitness_center,
                    color: cs.primary,
                    share: macros.energyKcal <= 0
                        ? 0
                        : (macros.proteinG * 4) / macros.energyKcal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MacroStatCard(
                    label: 'Carbs',
                    arabicLabel: 'كربوهيدرات',
                    value: macros.carbohydrateG,
                    icon: Icons.grain,
                    color: context.appColors.carbs,
                    share: macros.energyKcal <= 0
                        ? 0
                        : (macros.carbohydrateG * 4) / macros.energyKcal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MacroStatCard(
                    label: 'Fats',
                    arabicLabel: 'دهون',
                    value: macros.fatG,
                    icon: Icons.water_drop_outlined,
                    color: context.appColors.warning,
                    share: macros.energyKcal <= 0
                        ? 0
                        : (macros.fatG * 9) / macros.energyKcal,
                  ),
                ),
              ],
            ),
            if (budget != null && budget > 0) ...[
              const SizedBox(height: 16),
              BudgetImpactCard(
                budgetEgp: budget,
                currentSpentEgp: spent,
                addedCostEgp: price ?? 0,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 2,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. grilled, no oil',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_submitting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.add_circle_outline),
                    const SizedBox(width: 8),
                    Text(
                      widget.mode == FoodActionMode.addToPlan
                          ? 'ADD TO PLAN'
                          : 'ADD TO LOG',
                    ),
                    if (price != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '· ${egp(price)}',
                        style: text.labelMedium!.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      ),
    );
  }
}

class _PlanBanner extends StatelessWidget {
  const _PlanBanner({this.plan});

  final MealPlan? plan;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final plan = this.plan;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.event_note_outlined, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              plan == null
                  ? 'Adding to a meal plan'
                  : 'Adding to plan for ${friendlyDate(plan.date)}',
              style: text.bodySmall!.copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodHero extends StatelessWidget {
  const _FoodHero({
    required this.food,
    required this.grams,
    required this.price,
  });

  final FoodItem food;
  final double grams;
  final double? price;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final priceLabel = price == null
        ? null
        : '${egp(price)} / ${_basisLabel(food)}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.65),
            cs.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  food.category.trim().isEmpty
                      ? 'EGYPTIAN FOOD'
                      : food.category.toUpperCase(),
                  style: text.labelSmall!.copyWith(color: cs.primary),
                ),
              ),
              const Spacer(),
              if (food.isPriceStale && food.priceEgp != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.5),
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
                        'PRICE MAY BE STALE',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 28,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.nameEn,
                      style: text.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (food.nameAr != null &&
                        food.nameAr!.trim().isNotEmpty)
                      Text(
                        food.nameAr!,
                        textDirection: TextDirection.rtl,
                        style: text.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _HeroMetric(
                icon: Icons.local_fire_department_outlined,
                value: '${food.per100g.energyKcal.round()} kcal / 100g',
              ),
              _HeroMetric(
                icon: Icons.straighten,
                value: '${gramsLabel(grams)} selected',
              ),
              if (priceLabel != null)
                _HeroMetric(
                  icon: Icons.account_balance_wallet_outlined,
                  value: priceLabel,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _basisLabel(FoodItem food) {
    return switch (food.priceBasis) {
      _ when food.priceBasis.name == 'weight' => 'kg',
      _ when food.priceBasis.name == 'drink' => 'drink',
      _ => 'serving',
    };
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: cs.primary),
        const SizedBox(width: 5),
        Text(
          value,
          style: text.labelMedium!.copyWith(color: cs.onSurface),
        ),
      ],
    );
  }
}

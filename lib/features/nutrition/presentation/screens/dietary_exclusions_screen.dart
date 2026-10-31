import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';
import 'package:spotter/features/nutrition/presentation/bloc/nutrition_preferences_bloc/nutrition_preferences_bloc.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';

/// Manages the dietary guardrails used by the meal planner. Exclusions are
/// stored as free-form categories (and optional catalogue food ids).
class DietaryExclusionsScreen extends StatefulWidget {
  const DietaryExclusionsScreen({super.key, required this.uid});

  final String uid;

  @override
  State<DietaryExclusionsScreen> createState() =>
      _DietaryExclusionsScreenState();
}

class _DietaryExclusionsScreenState extends State<DietaryExclusionsScreen> {
  static const _suggestions = [
    'Gluten',
    'Dairy',
    'Added Sugar',
    'Red Meat',
    'Lactose',
    'Peanuts',
    'Shellfish',
    'Soy',
  ];

  final TextEditingController _newController = TextEditingController();
  final Set<String> _categories = {};
  final Set<String> _foodIds = {};
  final Map<String, String> _foodNames = {};
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<NutritionPreferencesBloc>();
    final prefs = bloc.state.preferences;
    if (prefs != null) {
      _categories.addAll(prefs.excludedCategories);
      _foodIds.addAll(prefs.excludedFoodIds);
      _initialized = true;
      _loadFoodNames();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        bloc.add(
          NutritionPreferencesRequested(
            uid: widget.uid,
            prefsId: prefs?.prefsId ?? '',
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _newController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodNames() async {
    if (_foodIds.isEmpty) return;
    final foods = await fetchFoodsById(_foodIds);
    if (!mounted) return;
    setState(() {
      for (final entry in foods.entries) {
        _foodNames[entry.key] = entry.value.nameEn;
      }
    });
  }

  void _onState(NutritionPreferencesState state) {
    final cs = Theme.of(context).colorScheme;
    if (state is NutritionPreferencesLoaded && !_initialized) {
      _initialized = true;
      final prefs = state.preferences;
      setState(() {
        _categories
          ..clear()
          ..addAll(prefs?.excludedCategories ?? const <String>{});
        _foodIds
          ..clear()
          ..addAll(prefs?.excludedFoodIds ?? const <String>{});
      });
      _loadFoodNames();
    } else if (state is NutritionPreferencesSavedState && _saving) {
      setState(() => _saving = false);
      SnackBarBuilder.showSnackBar(
        context,
        state.message ?? 'Dietary preferences saved.',
        false,
        cs,
      );
      Navigator.pop(context, true);
    } else if (state is NutritionPreferencesError) {
      setState(() => _saving = false);
      SnackBarBuilder.showSnackBar(context, state.message, true, cs);
    }
  }

  void _addExclusion(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    setState(() {
      _categories.add(text);
      _newController.clear();
    });
  }

  void _save() {
    if (_saving) return;
    final bloc = context.read<NutritionPreferencesBloc>();
    final prefs = bloc.state.preferences;
    final profileState = context.read<ProfileBloc>().state;
    final metrics = profileState is ProfileLoaded
        ? profileState.bodyMetrics
        : null;
    final base =
        prefs ??
        DietaryPreferences(
          uid: widget.uid,
          prefsId: prefs?.prefsId ?? '',
          excludedFoodIds: const <String>{},
          excludedCategories: const <String>{},
          targetKcal: metrics?.macroTargets.calories.toDouble() ?? 0,
          targetProteinG: metrics?.macroTargets.proteinG.toDouble() ?? 0,
          targetCarbG: metrics?.macroTargets.carbsG.toDouble() ?? 0,
          targetFatG: metrics?.macroTargets.fatG.toDouble() ?? 0,
          schemaVersion: 1,
          createdAt: DateTime.now(),
        );
    final updated = DietaryPreferences(
      uid: base.uid,
      excludedFoodIds: Set<String>.from(_foodIds),
      prefsId: prefs?.prefsId ?? '',
      excludedCategories: Set<String>.from(_categories),
      targetKcal: base.targetKcal,
      targetProteinG: base.targetProteinG,
      targetCarbG: base.targetCarbG,
      targetFatG: base.targetFatG,
      budgetEgp: base.budgetEgp,
      dietTag: base.dietTag,
      schemaVersion: base.schemaVersion,
      createdAt: base.createdAt,
      updatedAt: DateTime.now(),
    );
    setState(() => _saving = true);
    bloc.add(NutritionPreferencesSaved(uid: widget.uid, preferences: updated));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final total = _categories.length + _foodIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dietary exclusions', style: text.headlineMedium),
      ),
      body: BlocConsumer<NutritionPreferencesBloc, NutritionPreferencesState>(
        listener: (context, state) => _onState(state),
        builder: (context, state) {
          if (state is NutritionPreferencesLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: cs.error,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DIETARY EXCLUSIONS', style: text.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Smart Gym filters recipes and cafeteria suggestions '
                            'based on your food intolerances.',
                            style: text.bodySmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTIVE GUARDRAIL',
                            style: text.labelSmall!.copyWith(
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Real-time menu stripping active',
                            style: text.bodySmall!.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$total',
                      style: text.headlineMedium!.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ITEMS',
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionTitle(title: 'ACTIVE EXCLUSIONS'),
              const SizedBox(height: 8),
              if (total == 0)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    'No exclusions yet. Add an ingredient or pick a quick '
                    'suggestion below.',
                    style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in _categories)
                        _ExclusionChip(
                          label: category,
                          onDeleted: () =>
                              setState(() => _categories.remove(category)),
                        ),
                      for (final foodId in _foodIds)
                        _ExclusionChip(
                          label: _foodNames[foodId] ?? 'Food item',
                          onDeleted: () =>
                              setState(() => _foodIds.remove(foodId)),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.45)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADD EXCLUSION',
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: _addExclusion,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Lactose, peanuts, raw onion',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: () => _addExclusion(_newController.text),
                            child: const Text('ADD'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionTitle(title: 'QUICK SUGGESTIONS'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final suggestion in _suggestions)
                    if (!_categories.any(
                      (item) => item.toLowerCase() == suggestion.toLowerCase(),
                    ))
                      _SuggestionChip(
                        label: suggestion,
                        onTap: () => _addExclusion(suggestion),
                      ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_user_outlined,
                        size: 19,
                        color: cs.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GYM BAR SYNC',
                            style: text.labelSmall!.copyWith(
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Baristas and the kitchen tablet will automatically '
                            'highlight safe shake formulas.',
                            style: text.bodySmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('SAVE PREFERENCES'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _ExclusionChip extends StatelessWidget {
  const _ExclusionChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: text.labelMedium!.copyWith(color: cs.primary)),
          const SizedBox(width: 6),
          InkWell(
            onTap: onDeleted,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14, color: cs.primary),
              const SizedBox(width: 5),
              Text(
                label,
                style: text.labelMedium!.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

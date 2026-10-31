import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';
import 'package:spotter/features/nutrition/presentation/bloc/nutrition_preferences_bloc/nutrition_preferences_bloc.dart';

/// Daily calorie goal, macro split and EGP budget editor.
class MetabolicTargetsScreen extends StatefulWidget {
  const MetabolicTargetsScreen({super.key, required this.uid});

  final String uid;

  @override
  State<MetabolicTargetsScreen> createState() => _MetabolicTargetsScreenState();
}

class _MetabolicTargetsScreenState extends State<MetabolicTargetsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _budgetController = TextEditingController();
  final _dietTagController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final targets = profileState.bodyMetrics.macroTargets;
      _kcalController.text = targets.calories.toString();
      _proteinController.text = targets.proteinG.toString();
      _carbsController.text = targets.carbsG.toString();
      _fatController.text = targets.fatG.toString();
    }

    final bloc = context.read<NutritionPreferencesBloc>();
    final prefs = bloc.state.preferences;
    if (prefs != null) {
      _applyPreferences(prefs);
      _initialized = true;
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
    _kcalController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _budgetController.dispose();
    _dietTagController.dispose();
    super.dispose();
  }

  void _applyPreferences(DietaryPreferences prefs) {
    _kcalController.text = prefs.targetKcal.round().toString();
    _proteinController.text = prefs.targetProteinG.round().toString();
    _carbsController.text = prefs.targetCarbG.round().toString();
    _fatController.text = prefs.targetFatG.round().toString();
    _budgetController.text = prefs.budgetEgp == null
        ? ''
        : prefs.budgetEgp!.toStringAsFixed(0);
    _dietTagController.text = prefs.dietTag ?? '';
  }

  void _onState(NutritionPreferencesState state) {
    final cs = Theme.of(context).colorScheme;
    if (state is NutritionPreferencesLoaded && !_initialized) {
      _initialized = true;
      final prefs = state.preferences;
      if (prefs != null) {
        setState(() => _applyPreferences(prefs));
      }
    } else if (state is NutritionPreferencesSavedState && _saving) {
      setState(() => _saving = false);
      SnackBarBuilder.showSnackBar(
        context,
        state.message ?? 'Macro targets saved.',
        false,
        cs,
      );
      Navigator.pop(context, true);
    } else if (state is NutritionPreferencesError) {
      setState(() => _saving = false);
      SnackBarBuilder.showSnackBar(context, state.message, true, cs);
    }
  }

  void _save() {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bloc = context.read<NutritionPreferencesBloc>();
    final prefs = bloc.state.preferences;
    final base =
        prefs ??
        DietaryPreferences(
          uid: widget.uid,
          excludedFoodIds: const <String>{},
          excludedCategories: const <String>{},
          prefsId: prefs?.prefsId ?? '',
          targetKcal: 0,
          targetProteinG: 0,
          targetCarbG: 0,
          targetFatG: 0,
          schemaVersion: 1,
          createdAt: DateTime.now(),
        );
    final budgetText = _budgetController.text.trim();
    final updated = DietaryPreferences(
      uid: base.uid,
      prefsId: prefs?.prefsId ?? '',
      excludedFoodIds: base.excludedFoodIds,
      excludedCategories: base.excludedCategories,
      targetKcal: double.parse(_kcalController.text.trim()),
      targetProteinG: double.parse(_proteinController.text.trim()),
      targetCarbG: double.parse(_carbsController.text.trim()),
      targetFatG: double.parse(_fatController.text.trim()),
      budgetEgp: budgetText.isEmpty ? null : double.tryParse(budgetText),
      dietTag: _dietTagController.text.trim().isEmpty
          ? null
          : _dietTagController.text.trim(),
      schemaVersion: base.schemaVersion,
      createdAt: base.createdAt,
      updatedAt: DateTime.now(),
    );
    setState(() => _saving = true);
    bloc.add(NutritionPreferencesSaved(uid: widget.uid, preferences: updated));
  }

  double _value(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final profileState = context.watch<ProfileBloc>().state;
    final metrics = profileState is ProfileLoaded
        ? profileState.bodyMetrics
        : null;
    final kcal = _value(_kcalController);
    final protein = _value(_proteinController);
    final carbs = _value(_carbsController);
    final fat = _value(_fatController);
    final proteinKcal = protein * 4;
    final carbsKcal = carbs * 4;
    final fatKcal = fat * 9;
    final splitTotal = proteinKcal + carbsKcal + fatKcal;
    final proteinShare = splitTotal <= 0 ? 0.0 : proteinKcal / splitTotal;
    final carbsShare = splitTotal <= 0 ? 0.0 : carbsKcal / splitTotal;
    final fatShare = splitTotal <= 0 ? 0.0 : fatKcal / splitTotal;

    return Scaffold(
      appBar: AppBar(title: Text('Macro targets', style: text.headlineMedium)),
      body: BlocConsumer<NutritionPreferencesBloc, NutritionPreferencesState>(
        listener: (context, state) => _onState(state),
        builder: (context, state) {
          if (state is NutritionPreferencesLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
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
                    children: [
                      Text(
                        'YOUR METABOLIC TARGET',
                        textAlign: TextAlign.center,
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'DAILY CALORIE GOAL',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            DateFormatter.thousands(kcal),
                            style: text.displayLarge!.copyWith(
                              color: cs.primary,
                              fontSize: 48,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'kcal/day',
                            style: text.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Target intake for optimal body recomposition',
                        textAlign: TextAlign.center,
                        style: text.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (metrics != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'TDEE ${DateFormatter.thousands(metrics.tdee)} kcal · '
                          'BMI ${metrics.bmi.toStringAsFixed(1)}',
                          style: text.labelSmall!.copyWith(color: cs.secondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                          Expanded(
                            child: Text(
                              'MACRO TARGETS',
                              style: text.titleLarge,
                            ),
                          ),
                          Text(
                            'DAILY SPLIT',
                            style: text.labelSmall!.copyWith(
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _MacroSplitBar(
                        proteinShare: proteinShare,
                        carbsShare: carbsShare,
                        fatShare: fatShare,
                        proteinColor: cs.primary,
                        carbsColor: cs.secondary,
                        fatColor: cs.outline,
                      ),
                      const SizedBox(height: 12),
                      _MacroRow(
                        color: cs.primary,
                        grams: protein,
                        label: 'Protein',
                        share: proteinShare,
                      ),
                      const SizedBox(height: 8),
                      _MacroRow(
                        color: cs.secondary,
                        grams: carbs,
                        label: 'Carbs',
                        share: carbsShare,
                      ),
                      const SizedBox(height: 8),
                      _MacroRow(
                        color: cs.outline,
                        grams: fat,
                        label: 'Fats',
                        share: fatShare,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'EDIT TARGETS',
                  style: text.labelSmall!.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _NumberField(
                  controller: _kcalController,
                  label: 'Daily calories',
                  suffix: 'kcal',
                  onChanged: () => setState(() {}),
                  validator: _positiveValidator,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _proteinController,
                        label: 'Protein',
                        suffix: 'g',
                        onChanged: () => setState(() {}),
                        validator: _nonNegativeValidator,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _NumberField(
                        controller: _carbsController,
                        label: 'Carbs',
                        suffix: 'g',
                        onChanged: () => setState(() {}),
                        validator: _nonNegativeValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _fatController,
                        label: 'Fats',
                        suffix: 'g',
                        onChanged: () => setState(() {}),
                        validator: _nonNegativeValidator,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _NumberField(
                        controller: _budgetController,
                        label: 'Daily budget',
                        suffix: 'EGP',
                        optional: true,
                        onChanged: () => setState(() {}),
                        validator: _budgetValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dietTagController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Diet tag (optional)',
                    hintText: 'e.g. halal, vegan, vegetarian',
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
                    label: const Text('SAVE TARGETS'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Smart Gym is a wellness aid, not a medical device.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall!.copyWith(color: cs.outline),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _positiveValidator(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) return 'Enter a value above zero';
    return null;
  }

  String? _nonNegativeValidator(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) return 'Enter zero or more';
    return null;
  }

  String? _budgetValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) return 'Enter a valid EGP amount';
    return null;
  }
}

class _MacroSplitBar extends StatelessWidget {
  const _MacroSplitBar({
    required this.proteinShare,
    required this.carbsShare,
    required this.fatShare,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
  });

  final double proteinShare;
  final double carbsShare;
  final double fatShare;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 8,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final proteinWidth = width * proteinShare.clamp(0.0, 1.0);
            final carbsWidth = width * carbsShare.clamp(0.0, 1.0);
            final fatWidth = width * fatShare.clamp(0.0, 1.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: cs.surfaceContainerHighest),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: proteinWidth,
                  child: ColoredBox(color: proteinColor),
                ),
                Positioned(
                  left: proteinWidth,
                  top: 0,
                  bottom: 0,
                  width: carbsWidth,
                  child: ColoredBox(color: carbsColor),
                ),
                Positioned(
                  left: proteinWidth + carbsWidth,
                  top: 0,
                  bottom: 0,
                  width: fatWidth,
                  child: ColoredBox(color: fatColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.color,
    required this.grams,
    required this.label,
    required this.share,
  });

  final Color color;
  final double grams;
  final String label;
  final double share;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '${grams.round()} g',
            style: text.titleLarge!.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Text(
            '${(share * 100).round()}%',
            style: text.labelMedium!.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.onChanged,
    required this.validator,
    this.optional = false,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final VoidCallback onChanged;
  final String? Function(String?) validator;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: (_) => onChanged(),
      validator: validator,
      decoration: InputDecoration(
        labelText: optional ? '$label (optional)' : label,
        suffixText: suffix,
      ),
    );
  }
}

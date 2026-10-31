import 'package:flutter/material.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_log_params.dart';
import 'package:spotter/features/nutrition/presentation/widgets/portion_selector.dart';

/// Opens the editor for one logged food. Returns the update parameters, or
/// `null` when the user dismisses the sheet.
Future<UpdateMealLogParams?> showMealLogEditSheet(
  BuildContext context, {
  required String uid,
  required MealLog log,
  FoodItem? food,
}) {
  return showModalBottomSheet<UpdateMealLogParams>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => _MealLogEditSheet(uid: uid, log: log, food: food),
  );
}

class _MealLogEditSheet extends StatefulWidget {
  const _MealLogEditSheet({
    required this.uid,
    required this.log,
    this.food,
  });

  final String uid;
  final MealLog log;
  final FoodItem? food;

  @override
  State<_MealLogEditSheet> createState() => _MealLogEditSheetState();
}

class _MealLogEditSheetState extends State<_MealLogEditSheet> {
  late Portion _portion = widget.log.portion;
  late double _servings = widget.log.servingsCount;
  late final TextEditingController _noteController = TextEditingController(
    text: widget.log.note ?? '',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final note = _noteController.text.trim();
    Navigator.pop(
      context,
      UpdateMealLogParams(
        uid: widget.uid,
        mealLogId: widget.log.mealLogId,
        portion: widget.food == null ? null : _portion,
        servingsCount: _servings,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final food = widget.food;
    final name = food?.nameEn ?? 'Logged food';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EDIT LOG',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(name, style: text.headlineMedium),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (food != null) ...[
              const SizedBox(height: 14),
              PortionSelector(
                food: food,
                portion: _portion,
                servings: _servings,
                onPortionChanged: (portion) =>
                    setState(() => _portion = portion),
                onServingsChanged: (value) =>
                    setState(() => _servings = value),
              ),
            ] else ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'SERVINGS',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _servings <= 0.5
                          ? null
                          : () => setState(
                              () => _servings = (_servings - 0.5).clamp(
                                0.5,
                                20,
                              ),
                            ),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      _servings.toStringAsFixed(1),
                      style: text.titleLarge!.copyWith(color: cs.primary),
                    ),
                    IconButton(
                      onPressed: _servings >= 20
                          ? null
                          : () => setState(
                              () => _servings = (_servings + 0.5).clamp(
                                0.5,
                                20,
                              ),
                            ),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              maxLines: 2,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. extra sauce, half portion',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

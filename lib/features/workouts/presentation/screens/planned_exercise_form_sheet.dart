import 'package:flutter/material.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';

class PlannedExerciseFormResult {
  const PlannedExerciseFormResult({
    required this.targetSets,
    required this.targetReps,
    required this.targetLoad,
    required this.targetTempo,
    required this.restSec,
  });

  final int targetSets;
  final int targetReps;
  final double targetLoad;
  final String targetTempo;
  final int restSec;
}

Future<PlannedExerciseFormResult?> showPlannedExerciseSheet(
  BuildContext context, {
  required String exerciseName,
  PlannedExercise? existing,
}) {
  return showModalBottomSheet<PlannedExerciseFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 280),
      reverseDuration: Duration(milliseconds: 220),
    ),
    builder: (context) => PlannedExerciseFormSheet(
      exerciseName: exerciseName,
      existing: existing,
    ),
  );
}

class PlannedExerciseFormSheet extends StatefulWidget {
  const PlannedExerciseFormSheet({
    super.key,
    required this.exerciseName,
    this.existing,
  });

  final String exerciseName;
  final PlannedExercise? existing;

  @override
  State<PlannedExerciseFormSheet> createState() =>
      _PlannedExerciseFormSheetState();
}

class _PlannedExerciseFormSheetState extends State<PlannedExerciseFormSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();
  late final TextEditingController setsController;
  late final TextEditingController repsController;
  late final TextEditingController loadController;
  late final TextEditingController tempoController;
  late final TextEditingController restController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    setsController = TextEditingController(
      text: '${existing?.targetSets ?? 3}',
    );
    repsController = TextEditingController(
      text: '${existing?.targetReps ?? 10}',
    );
    loadController = TextEditingController(
      text: '${existing?.targetLoad ?? 20}',
    );
    tempoController = TextEditingController(
      text: existing?.targetTempo ?? '3-1-1',
    );
    restController = TextEditingController(text: '${existing?.restSec ?? 90}');
  }

  @override
  void dispose() {
    setsController.dispose();
    repsController.dispose();
    loadController.dispose();
    tempoController.dispose();
    restController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      PlannedExerciseFormResult(
        targetSets: int.parse(setsController.text.trim()),
        targetReps: int.parse(repsController.text.trim()),
        targetLoad: double.parse(loadController.text.trim()),
        targetTempo: tempoController.text.trim(),
        restSec: int.parse(restController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'EDIT EXERCISE' : 'ADD EXERCISE',
                style: text.labelSmall!.copyWith(
                  color: cs.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.exerciseName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.headlineMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      label: 'TARGET SETS',
                      controller: setsController,
                      isDecimal: false,
                      suffix: 'sets',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _numberField(
                      label: 'TARGET REPS',
                      controller: repsController,
                      isDecimal: false,
                      suffix: 'reps',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      label: 'TARGET LOAD',
                      controller: loadController,
                      isDecimal: true,
                      suffix: 'kg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _numberField(
                      label: 'REST',
                      controller: restController,
                      isDecimal: false,
                      suffix: 'sec',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'TARGET TEMPO',
                style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: tempoController,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  hintText: 'e.g. 3-1-1',
                  prefixIcon: Icon(Icons.speed_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the target tempo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: Text(isEditing ? 'SAVE CHANGES' : 'ADD TO WORKOUT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    required bool isDecimal,
    required String suffix,
  }) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          decoration: InputDecoration(suffixText: suffix, isDense: true),
          validator: (value) {
            final raw = value?.trim() ?? '';
            if (raw.isEmpty) return 'Required';
            final parsed = isDecimal ? double.tryParse(raw) : int.tryParse(raw);
            if (parsed == null) return 'Invalid';
            if (parsed <= 0) return 'Must be > 0';
            return null;
          },
        ),
      ],
    );
  }
}

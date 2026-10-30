import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';

class WorkoutFormResult {
  const WorkoutFormResult({required this.name, required this.scheduledFor});

  final String name;
  final DateTime scheduledFor;
}

Future<WorkoutFormResult?> showWorkoutFormSheet(
  BuildContext context, {
  required String title,
  String confirmLabel = 'SAVE',
  String name = 'Workout',
  DateTime? scheduledFor,
  bool requireFuture = false,
}) {
  return showModalBottomSheet<WorkoutFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 280),
      reverseDuration: Duration(milliseconds: 220),
    ),
    builder: (context) => WorkoutFormSheet(
      title: title,
      confirmLabel: confirmLabel,
      name: name,
      scheduledFor: scheduledFor ?? DateTime.now(),
      requireFuture: requireFuture,
    ),
  );
}

class WorkoutFormSheet extends StatefulWidget {
  const WorkoutFormSheet({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.name,
    required this.scheduledFor,
    this.requireFuture = false,
  });

  final String title;
  final String confirmLabel;
  final String name;
  final DateTime scheduledFor;

  /// When true (creating a workout) the schedule must never be in the past.
  /// When false (editing) only a schedule the user actually changes has to be
  /// in the future, so old workouts can still be renamed.
  final bool requireFuture;

  @override
  State<WorkoutFormSheet> createState() => _WorkoutFormSheetState();
}

class _WorkoutFormSheetState extends State<WorkoutFormSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();
  late final TextEditingController nameController;
  late DateTime scheduledFor;
  bool scheduleChanged = false;
  String? scheduleError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    scheduledFor = widget.requireFuture
        ? _nextMinute(widget.scheduledFor)
        : widget.scheduledFor;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  static DateTime _nextMinute(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    ).add(const Duration(minutes: 1));
  }

  bool _isPast(DateTime value) => value.isBefore(DateTime.now());

  void _updateSchedule(DateTime value) {
    setState(() {
      scheduledFor = value;
      scheduleChanged = true;
      scheduleError = _isPast(value)
          ? 'Pick a date and time in the future.'
          : null;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = scheduledFor.isBefore(today) ? today : scheduledFor;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null || !mounted) return;

    _updateSchedule(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        scheduledFor.hour,
        scheduledFor.minute,
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(scheduledFor),
    );
    if (picked == null || !mounted) return;

    _updateSchedule(
      DateTime(
        scheduledFor.year,
        scheduledFor.month,
        scheduledFor.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;

    var target = scheduledFor;
    final mustBeFuture = widget.requireFuture || scheduleChanged;

    if (mustBeFuture && _isPast(target)) {
      // A freshly created plan may have been sitting open for a while: move it
      // to the next minute instead of blocking the user. A date the user chose
      // explicitly must be corrected by them.
      if (scheduleChanged) {
        setState(() => scheduleError = 'Pick a date and time in the future.');
        return;
      }
      target = _nextMinute(DateTime.now());
    }

    Navigator.pop(
      context,
      WorkoutFormResult(name: nameController.text.trim(), scheduledFor: target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

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
                widget.title,
                style: text.labelSmall!.copyWith(
                  color: cs.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text('Name and schedule', style: text.headlineMedium),
              const SizedBox(height: 16),
              Text(
                'WORKOUT NAME',
                style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: const InputDecoration(
                  hintText: 'Push day, Legs, Full body…',
                  isDense: true,
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Give your workout a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: _pickerTile(
                      label: 'DATE',
                      value: DateFormatter.date(scheduledFor),
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _pickerTile(
                      label: 'TIME',
                      value: DateFormatter.clock(scheduledFor),
                      icon: Icons.schedule,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: scheduleError == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 14,
                              color: cs.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                scheduleError!,
                                style: text.bodySmall!.copyWith(
                                  color: cs.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: Text(widget.confirmLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

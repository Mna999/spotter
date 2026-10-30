import 'package:flutter/material.dart';

class SetFormResult {
  const SetFormResult({
    required this.reps,
    required this.load,
    required this.timeUnderTension,
    required this.restSec,
  });

  final int reps;
  final double load;
  final int timeUnderTension;
  final int restSec;
}

Future<SetFormResult?> showSetFormSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required int reps,
  required double load,
  required int timeUnderTension,
  required int restSec,
  String confirmLabel = 'LOG SET',
}) {
  return showModalBottomSheet<SetFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 280),
      reverseDuration: Duration(milliseconds: 220),
    ),
    builder: (context) => SetFormSheet(
      title: title,
      subtitle: subtitle,
      reps: reps,
      load: load,
      timeUnderTension: timeUnderTension,
      restSec: restSec,
      confirmLabel: confirmLabel,
    ),
  );
}

class SetFormSheet extends StatefulWidget {
  const SetFormSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.reps,
    required this.load,
    required this.timeUnderTension,
    required this.restSec,
    required this.confirmLabel,
  });

  final String title;
  final String subtitle;
  final int reps;
  final double load;
  final int timeUnderTension;
  final int restSec;
  final String confirmLabel;

  @override
  State<SetFormSheet> createState() => _SetFormSheetState();
}

class _SetFormSheetState extends State<SetFormSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();
  late final TextEditingController repsController;
  late final TextEditingController loadController;
  late final TextEditingController tutController;
  late final TextEditingController restController;

  @override
  void initState() {
    super.initState();
    repsController = TextEditingController(text: '${widget.reps}');
    loadController = TextEditingController(text: '${widget.load}');
    tutController = TextEditingController(text: '${widget.timeUnderTension}');
    restController = TextEditingController(text: '${widget.restSec}');
  }

  @override
  void dispose() {
    repsController.dispose();
    loadController.dispose();
    tutController.dispose();
    restController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      SetFormResult(
        reps: int.parse(repsController.text.trim()),
        load: double.parse(loadController.text.trim()),
        timeUnderTension: int.parse(tutController.text.trim()),
        restSec: int.parse(restController.text.trim()),
      ),
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
              Text(
                widget.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.headlineMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      label: 'REPS',
                      controller: repsController,
                      isDecimal: false,
                      suffix: 'reps',
                      allowZero: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _numberField(
                      label: 'LOAD',
                      controller: loadController,
                      isDecimal: true,
                      suffix: 'kg',
                      allowZero: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      label: 'TIME UNDER TENSION',
                      controller: tutController,
                      isDecimal: false,
                      suffix: 'sec',
                      allowZero: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _numberField(
                      label: 'REST AFTER SET',
                      controller: restController,
                      isDecimal: false,
                      suffix: 'sec',
                      allowZero: true,
                    ),
                  ),
                ],
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

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    required bool isDecimal,
    required String suffix,
    required bool allowZero,
  }) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
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
            if (allowZero ? parsed < 0 : parsed <= 0) return 'Invalid';
            return null;
          },
        ),
      ],
    );
  }
}

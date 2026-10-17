import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotter/core/input_converter/input_validator.dart';
import 'package:spotter/features/auth/presentation/widgets/text_form_title.dart';

class BodyStep extends StatelessWidget {
  const BodyStep({
    super.key,
    required this.heightController,
    required this.weightController,
    required this.onChanged,
  });

  final TextEditingController heightController;
  final TextEditingController weightController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are your height and weight?', style: text.headlineMedium),
          const SizedBox(height: 20),
          TextFormTitle(text: text, cs: cs, title: 'HEIGHT'),
          const SizedBox(height: 10),
          TextFormField(
            controller: heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: InputValidator.validateHeight,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.height),
              suffixText: 'cm',
              hintText: '175',
            ),
          ),
          const SizedBox(height: 20),
          TextFormTitle(text: text, cs: cs, title: 'WEIGHT'),
          const SizedBox(height: 10),
          TextFormField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: InputValidator.validateWeight,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.monitor_weight_outlined),
              suffixText: 'kg',
              hintText: '70',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Used to calculate your BMI and daily calories.',
            style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
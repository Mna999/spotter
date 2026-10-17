import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotter/core/input_converter/input_validator.dart';
import 'package:spotter/features/auth/presentation/widgets/options_card.dart';
import 'package:spotter/features/auth/presentation/widgets/text_form_title.dart';

class AboutYouStep extends StatelessWidget {
  const AboutYouStep({
    super.key,
    required this.isMale,
    required this.onSexChanged,
    required this.ageController,
    required this.onAgeChanged,
  });

  final bool? isMale;
  final ValueChanged<bool> onSexChanged;
  final TextEditingController ageController;
  final VoidCallback onAgeChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about yourself', style: text.headlineMedium),
          const SizedBox(height: 20),
          TextFormTitle(text: text, cs: cs, title: 'SEX'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OptionCard(
                  title: 'Male',
                  icon: Icons.male,
                  isSelected: isMale == true,
                  onTap: () => onSexChanged(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OptionCard(
                  title: 'Female',
                  icon: Icons.female,
                  isSelected: isMale == false,
                  onTap: () => onSexChanged(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormTitle(text: text, cs: cs, title: 'AGE'),
          const SizedBox(height: 10),
          TextFormField(
            controller: ageController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: InputValidator.validateAge,
            onChanged: (_) => onAgeChanged(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.cake_outlined),
              suffixText: 'years',
              hintText: '25',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Used to estimate your calorie needs and heart-rate zones.',
            style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

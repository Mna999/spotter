import 'package:flutter/material.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/presentation/widgets/option_list.dart';
import 'package:spotter/features/auth/presentation/widgets/text_form_title.dart';

class LifestyleStep extends StatelessWidget {
  const LifestyleStep({
    super.key,
    required this.activityLevel,
    required this.onActivityChanged,
    required this.equipmentAccess,
    required this.onEquipmentChanged,
  });

  final ActivityLevel? activityLevel;
  final ValueChanged<ActivityLevel> onActivityChanged;
  final EquipmentAccess? equipmentAccess;
  final ValueChanged<EquipmentAccess> onEquipmentChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final equipmentDescription = switch (equipmentAccess) {
      EquipmentAccess.fullGym => 'Machines, barbells and dumbbells',
      EquipmentAccess.homeMinimal => 'Dumbbells, bands and basic gear',
      EquipmentAccess.bodyweightOnly => 'No equipment needed',
      null => 'Choose where you usually train.',
    };
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How active are you?', style: text.headlineMedium),
          const SizedBox(height: 20),
          TextFormTitle(text: text, cs: cs, title: 'ACTIVITY LEVEL'),
          const SizedBox(height: 10),
          OptionList<ActivityLevel>(
            options: const [
              (
                ActivityLevel.sedentary,
                'Sedentary',
                'Little or no exercise',
                null,
              ),
              (
                ActivityLevel.lightlyActive,
                'Lightly Active',
                'Light exercise 1–3 days/week',
                null,
              ),
              (
                ActivityLevel.moderatelyActive,
                'Moderately Active',
                'Moderate exercise 3–5 days/week',
                null,
              ),
              (
                ActivityLevel.veryActive,
                'Very Active',
                'Hard exercise 6–7 days/week',
                null,
              ),
              (
                ActivityLevel.extraActive,
                'Extra Active',
                'Very hard exercise and a physical job',
                null,
              ),
            ],
            selected: activityLevel,
            onSelected: onActivityChanged,
          ),
          const SizedBox(height: 10),
          TextFormTitle(text: text, cs: cs, title: 'EQUIPMENT ACCESS'),
          const SizedBox(height: 10),
          SegmentedButton<EquipmentAccess>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            expandedInsets: EdgeInsets.zero,
            segments: const [
              ButtonSegment(
                value: EquipmentAccess.fullGym,
                label: Text('Full gym'),
              ),
              ButtonSegment(
                value: EquipmentAccess.homeMinimal,
                label: Text('Home'),
              ),
              ButtonSegment(
                value: EquipmentAccess.bodyweightOnly,
                label: Text('Bodyweight'),
              ),
            ],
            selected: equipmentAccess == null
                ? <EquipmentAccess>{}
                : {equipmentAccess!},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) onEquipmentChanged(selection.first);
            },
          ),
          const SizedBox(height: 10),
          Text(
            equipmentDescription,
            style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

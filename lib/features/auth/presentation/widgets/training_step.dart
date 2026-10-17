import 'package:flutter/material.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/presentation/widgets/counter_tile.dart';
import 'package:spotter/features/auth/presentation/widgets/option_list.dart';
import 'package:spotter/features/auth/presentation/widgets/text_form_title.dart';

class TrainingStep extends StatelessWidget {
  const TrainingStep({
    super.key,
    required this.experienceLevel,
    required this.onExperienceChanged,
    required this.trainingDays,
    required this.onTrainingDaysChanged,
  });

  final ExperienceLevel? experienceLevel;
  final ValueChanged<ExperienceLevel> onExperienceChanged;
  final int trainingDays;
  final ValueChanged<int> onTrainingDaysChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How do you train?', style: text.headlineMedium),
          const SizedBox(height: 20),
          TextFormTitle(text: text, cs: cs, title: 'EXPERIENCE LEVEL'),
          const SizedBox(height: 10),
          OptionList<ExperienceLevel>(
            options: [
              (
                ExperienceLevel.beginner,
                'Beginner',
                'New to training or returning after a long break',
                Icons.trending_flat,
              ),
              (
                ExperienceLevel.intermediate,
                'Intermediate',
                'Training regularly for 1–3 years',
                Icons.trending_up,
              ),
              (
                ExperienceLevel.advanced,
                'Advanced',
                '3+ years with structured programming',
                Icons.military_tech_outlined,
              ),
            ],
            selected: experienceLevel,
            onSelected: onExperienceChanged,
          ),
          const SizedBox(height: 10),
          TextFormTitle(text: text, cs: cs, title: 'TRAINING DAYS PER WEEK'),
          const SizedBox(height: 10),
          CounterTile(
            value: trainingDays,
            unit: 'days / week',
            onDecrement: trainingDays > 1
                ? () => onTrainingDaysChanged(trainingDays - 1)
                : null,
            onIncrement: trainingDays < 7
                ? () => onTrainingDaysChanged(trainingDays + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
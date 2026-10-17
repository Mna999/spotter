import 'package:flutter/material.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/presentation/widgets/option_list.dart';

class GoalStep extends StatelessWidget {
  const GoalStep({super.key, required this.goal, required this.onGoalChanged});

  final Goal? goal;
  final ValueChanged<Goal> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your primary fitness goal?', style: text.headlineMedium),
          const SizedBox(height: 20),
          OptionList<Goal>(
            options: [
              (
                Goal.buildMuscle,
                'Hypertrophy & Muscle Gain',
                'Increase muscle mass and definition',
                Icons.fitness_center,
              ),
              (
                Goal.loseFat,
                'Fat Loss & Conditioning',
                'Burn body fat and improve cardiovascular endurance',
                Icons.local_fire_department_outlined,
              ),
              (
                Goal.maintain,
                'General Health & Mobility',
                'Enhance functional movement and longevity',
                Icons.monitor_heart_outlined,
              ),
            ],
            selected: goal,
            onSelected: onGoalChanged,
          ),
        ],
      ),
    );
  }
}
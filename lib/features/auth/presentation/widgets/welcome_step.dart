import 'package:flutter/material.dart';
import 'package:spotter/features/auth/presentation/widgets/info_tile.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              './lib/core/assets/images/logo.png',
              width: 96,
              height: 96,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome to Spotter',
            textAlign: TextAlign.center,
            style: text.headlineLarge,
          ),
          const SizedBox(height: 5),
          Text(
            'BE SPOT ON.',
            style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text(
            'Answer a few quick questions so we can tailor your coaching and nutrition. It takes about a minute.',
            textAlign: TextAlign.center,
            style: text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: InfoTile(
              cs: cs,
              text: text,
              title: 'YOUR BODY',
              subtitle: 'Age, height and weight',
              icon: Icons.straighten,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: InfoTile(
              cs: cs,
              text: text,
              title: 'YOUR GOAL',
              subtitle: 'What you want to achieve',
              icon: Icons.flag_outlined,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: InfoTile(
              cs: cs,
              text: text,
              title: 'YOUR TRAINING',
              subtitle: 'Experience, activity and equipment',
              icon: Icons.fitness_center,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Spotter is a wellness aid, not a medical device.',
            textAlign: TextAlign.center,
            style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/auth/presentation/widgets/macro_goals_card.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';
import 'package:spotter/features/workouts/presentation/widgets/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Profile', style: text.headlineMedium)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            SnackBarBuilder.showSnackBar(context, state.message, true, cs);
          }
        },
        builder: (context, authState) {
          final account = authState is Authenticated
              ? authState.userAccount
              : null;
          final name = account?.displayName ?? 'Athlete';
          final email = account?.email ?? '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          name.isEmpty ? 'S' : name[0].toUpperCase(),
                          style: text.headlineMedium!.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleLarge,
                            ),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodySmall!.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  if (profileState is ProfileLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (profileState is ProfileError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          profileState.message,
                          style: text.bodySmall!.copyWith(color: cs.error),
                        ),
                      ),
                    );
                  }
                  if (profileState is! ProfileLoaded) {
                    return const SizedBox.shrink();
                  }

                  final profile = profileState.userProfile;
                  final metrics = profileState.bodyMetrics;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MacroGoalsCard(
                        macroTargets: metrics.macroTargets,
                        tdee: metrics.tdee,
                        bmi: metrics.bmi,
                        goal: profile.goal,
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'BODY METRICS'),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                  label: 'BMI',
                                  value: metrics.bmi.toStringAsFixed(1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StatTile(
                                  label: 'REE',
                                  value: metrics.ree.round().toString(),
                                  unit: 'kcal',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StatTile(
                                  label: 'TDEE',
                                  value: metrics.tdee.round().toString(),
                                  unit: 'kcal',
                                  accent: cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'TRAINING PROFILE'),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _infoRow(text, cs, 'Goal', _goal(profile.goal)),
                              _infoRow(
                                text,
                                cs,
                                'Experience',
                                _experience(profile.experienceLevel),
                              ),
                              _infoRow(
                                text,
                                cs,
                                'Activity',
                                _activity(profile.activityLevel),
                              ),
                              _infoRow(
                                text,
                                cs,
                                'Equipment',
                                _equipment(profile.equipmentAccess),
                              ),
                              _infoRow(
                                text,
                                cs,
                                'Training days',
                                '${profile.trainingDays} / week',
                              ),
                              _infoRow(
                                text,
                                cs,
                                'Weekly target',
                                '${profile.weeklyTargetMin} min',
                              ),
                              _infoRow(
                                text,
                                cs,
                                'Age / Sex',
                                '${profile.age} · '
                                    '${profile.isMale ? 'Male' : 'Female'}',
                              ),
                              _infoRow(
                                text,
                                cs,
                                'Height / Weight',
                                '${profile.height.round()} cm · '
                                    '${profile.weight.toStringAsFixed(1)} kg',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.read<AuthBloc>().add(SignOutRequested()),
                  icon: const Icon(Icons.logout),
                  label: const Text('SIGN OUT'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  style: OutlinedButton.styleFrom(foregroundColor: cs.error),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('DELETE ACCOUNT'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your profile, workouts, and logged sets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AccountDeletionRequested());
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(TextTheme text, ColorScheme cs, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _goal(Goal goal) => switch (goal) {
    Goal.loseFat => 'Lose fat',
    Goal.maintain => 'Maintain',
    Goal.buildMuscle => 'Build muscle',
  };

  String _experience(ExperienceLevel level) => switch (level) {
    ExperienceLevel.beginner => 'Beginner',
    ExperienceLevel.intermediate => 'Intermediate',
    ExperienceLevel.advanced => 'Advanced',
  };

  String _activity(ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => 'Sedentary',
    ActivityLevel.lightlyActive => 'Lightly active',
    ActivityLevel.moderatelyActive => 'Moderately active',
    ActivityLevel.veryActive => 'Very active',
    ActivityLevel.extraActive => 'Extra active',
  };

  String _equipment(EquipmentAccess access) => switch (access) {
    EquipmentAccess.fullGym => 'Full gym',
    EquipmentAccess.homeMinimal => 'Home (minimal)',
    EquipmentAccess.bodyweightOnly => 'Bodyweight only',
  };
}

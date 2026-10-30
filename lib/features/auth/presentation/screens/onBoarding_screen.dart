import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/input_converter/input_validator.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/onBoarding_bloc/on_boarding_bloc.dart';

import 'package:spotter/features/auth/presentation/widgets/about_you_step.dart';
import 'package:spotter/features/auth/presentation/widgets/body_step.dart';
import 'package:spotter/features/auth/presentation/widgets/goal_step.dart';
import 'package:spotter/features/auth/presentation/widgets/lifestyle_step.dart';
import 'package:spotter/features/auth/presentation/widgets/step_container.dart';
import 'package:spotter/features/auth/presentation/widgets/training_step.dart';
import 'package:spotter/features/auth/presentation/widgets/welcome_step.dart';
import 'package:spotter/main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int currIndex = 0;

  bool? isMale;
  TextEditingController ageController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  Goal? goal;
  ExperienceLevel? experienceLevel;
  int trainingDays = 3;
  ActivityLevel? activityLevel;
  EquipmentAccess? equipmentAccess;

  @override
  void dispose() {
    pageController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  bool get canGoNext => switch (currIndex) {
    0 => true,
    1 =>
      isMale != null && InputValidator.validateAge(ageController.text) == null,
    2 =>
      InputValidator.validateHeight(heightController.text) == null &&
          InputValidator.validateWeight(weightController.text) == null,
    3 => goal != null,
    4 => experienceLevel != null,
    5 => activityLevel != null && equipmentAccess != null,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final OnBoardingBloc onBoardingBloc = context.read<OnBoardingBloc>();
    final AuthBloc authBloc = context.read<AuthBloc>();
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETUP FLOW'),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.only(left: 5),
          child: Image.asset('./lib/core/assets/images/logo.png'),
        ),
      ),
      body: BlocConsumer<OnBoardingBloc, OnBoardingState>(
        listener: (context, state) {
          if (state is OnBoardingError)
            SnackBarBuilder.showSnackBar(context, state.message, true, cs);
          if (state is OnBoardingCompleted)
            Routing.routeReplacement(const MainShell(), context);
        },
        builder: (context, state) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'STEP ${currIndex + 1} OF 6',
                          style: text.labelMedium!.copyWith(color: cs.primary),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 10,
                        child: Row(
                          children: List.generate(
                            6,
                            (index) => Expanded(
                              child: StepContainer(
                                isActive: index <= currIndex,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (value) {
                            currIndex = value;
                            setState(() {});
                          },
                          children: [
                            const WelcomeStep(),
                            AboutYouStep(
                              isMale: isMale,
                              onSexChanged: (value) {
                                isMale = value;
                                setState(() {});
                              },
                              ageController: ageController,
                              onAgeChanged: () => setState(() {}),
                            ),
                            BodyStep(
                              heightController: heightController,
                              weightController: weightController,
                              onChanged: () => setState(() {}),
                            ),
                            GoalStep(
                              goal: goal,
                              onGoalChanged: (value) {
                                goal = value;
                                setState(() {});
                              },
                            ),
                            TrainingStep(
                              experienceLevel: experienceLevel,
                              onExperienceChanged: (value) {
                                experienceLevel = value;
                                setState(() {});
                              },
                              trainingDays: trainingDays,
                              onTrainingDaysChanged: (value) {
                                trainingDays = value;
                                setState(() {});
                              },
                            ),
                            LifestyleStep(
                              activityLevel: activityLevel,
                              onActivityChanged: (value) {
                                activityLevel = value;
                                setState(() {});
                              },
                              equipmentAccess: equipmentAccess,
                              onEquipmentChanged: (value) {
                                equipmentAccess = value;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (currIndex > 0)
                            FilledButton.icon(
                              onPressed: () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                );
                              },
                              label: const Text('Back'),
                              icon: const Icon(Icons.arrow_back),
                              iconAlignment: IconAlignment.start,
                              style: FilledButton.styleFrom(
                                backgroundColor: cs.secondaryContainer,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          const Spacer(),
                          const SizedBox(width: 10),
                          if (currIndex < 5)
                            Expanded(
                              flex: 20,
                              child: FilledButton.icon(
                                onPressed: canGoNext
                                    ? () {
                                        pageController.nextPage(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          curve: Curves.easeIn,
                                        );
                                      }
                                    : null,
                                label: const Text('Continue'),
                                icon: const Icon(Icons.arrow_forward),
                                iconAlignment: IconAlignment.end,
                              ),
                            ),

                          if (currIndex == 5)
                            Expanded(
                              flex: 20,
                              child: FilledButton.icon(
                                onPressed: canGoNext
                                    ? () {
                                        onBoardingBloc.add(
                                          OnBoardingSubmitted(
                                            onboardingParams: OnboardingParams(
                                              uid: state is Authenticated
                                                  ? state.userAccount.uid
                                                  : '',
                                              isMale: isMale ?? false,
                                              age: int.parse(
                                                ageController.text,
                                              ),
                                              height: double.parse(
                                                heightController.text,
                                              ),
                                              weight: double.parse(
                                                weightController.text,
                                              ),
                                              experienceLevel:
                                                  experienceLevel ??
                                                  ExperienceLevel.beginner,
                                              goal: goal ?? Goal.maintain,
                                              activityLevel:
                                                  activityLevel ??
                                                  ActivityLevel
                                                      .moderatelyActive,
                                              equipmentAccess:
                                                  equipmentAccess ??
                                                  EquipmentAccess.fullGym,
                                              trainingDays: trainingDays,
                                              weeklyTargetMin: 3,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                label: const Text('Finish'),
                                icon: const Icon(Icons.arrow_forward),
                                iconAlignment: IconAlignment.end,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/theme/app_theme.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/onBoarding_bloc/on_boarding_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/auth/presentation/screens/onBoarding_screen.dart';
import 'package:spotter/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:spotter/features/nutrition/presentation/bloc/food_log_bloc/food_log_bloc.dart';
import 'package:spotter/features/nutrition/presentation/bloc/meal_plan_bloc/meal_plan_bloc.dart';
import 'package:spotter/features/workouts/presentation/blocs/workout_session_bloc/workout_session_bloc.dart';
import 'package:spotter/firebase_options.dart';
import 'package:spotter/injection_container.dart';
import 'package:spotter/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(SessionRestoreRequested()),
        ),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<OnBoardingBloc>(create: (_) => sl<OnBoardingBloc>()),
        BlocProvider<WorkoutSessionBloc>(
          create: (_) => sl<WorkoutSessionBloc>(),
        ),
        BlocProvider<FoodLogBloc>(
          create: (_) => sl<FoodLogBloc>(),
        ),
        BlocProvider<MealPlanBloc>(
          create: (_) => sl<MealPlanBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spotter',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        builder: (context, child) => ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(top: false, child: child!),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) return const SignInScreen();

            return BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) => switch (profileState) {
                OnBoardingNotCompleted() => const OnboardingScreen(),
                ProfileLoaded() => const MainShell(),
                ProfileError(:final message) => Scaffold(
                  body: Center(child: Text(message)),
                ),
                _ => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              },
            );
          },
        ),
      ),
    );
  }
}

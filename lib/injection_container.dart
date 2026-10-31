import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:spotter/core/network/network_info.dart';
import 'package:spotter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:spotter/features/auth/data/datasources/profile_remote_data_source.dart';
import 'package:spotter/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:spotter/features/auth/data/repositories/profile_repo_impl.dart';
import 'package:spotter/features/auth/domain/repositories/auth_repo.dart';
import 'package:spotter/features/auth/domain/repositories/profile_repo.dart';
import 'package:spotter/features/auth/domain/usecases/check_email_verified_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/complete_on_boarding_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/compute_body_metrics_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/verify_account_usecase.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/onBoarding_bloc/on_boarding_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/nutrition/data/datasources/food_remote_data_source.dart';
import 'package:spotter/features/nutrition/data/datasources/meal_entry_remote_data_source.dart';
import 'package:spotter/features/nutrition/data/datasources/meal_log_remote_data_source.dart';
import 'package:spotter/features/nutrition/data/datasources/meal_plan_remote_data_source.dart';
import 'package:spotter/features/nutrition/data/datasources/nutrition_preferences_remote_data_source.dart';
import 'package:spotter/features/nutrition/data/repository/food_repo_impl.dart';
import 'package:spotter/features/nutrition/data/repository/meal_entry_repo_impl.dart';
import 'package:spotter/features/nutrition/data/repository/meal_log_repo_impl.dart';
import 'package:spotter/features/nutrition/data/repository/meal_plan_repo_impl.dart';
import 'package:spotter/features/nutrition/data/repository/nutrition_pref_repo_impl.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';
import 'package:spotter/features/nutrition/domain/usecases/add_meal_entry_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/create_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/delete_meal_log_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/delete_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/generate_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_daily_totals_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/list_meal_logs_for_date_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/list_recent_meal_plans_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/log_food_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/regen_under_budget_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/repeat_yesterday_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/save_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/update_meal_log_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/update_meal_plan_usecase.dart';
import 'package:spotter/features/nutrition/presentation/bloc/food_log_bloc/food_log_bloc.dart';
import 'package:spotter/features/nutrition/presentation/bloc/meal_plan_bloc/meal_plan_bloc.dart';
import 'package:spotter/features/workouts/data/datasources/exercise_remote_datasource.dart';
import 'package:spotter/features/workouts/data/datasources/planned_exercise_remote_datasource.dart';
import 'package:spotter/features/workouts/data/datasources/set_remote_datasource.dart';
import 'package:spotter/features/workouts/data/datasources/workout_remote_datasource.dart';
import 'package:spotter/features/workouts/data/repository/exercise_repo_impl.dart';
import 'package:spotter/features/workouts/data/repository/planned_exercise_repo_impl.dart';
import 'package:spotter/features/workouts/data/repository/set_repo_impl.dart';
import 'package:spotter/features/workouts/data/repository/workout_repo_impl.dart';
import 'package:spotter/features/workouts/domain/repository/exercise_repo.dart';
import 'package:spotter/features/workouts/domain/repository/planned_exercise_repo.dart';
import 'package:spotter/features/workouts/domain/repository/set_repo.dart';
import 'package:spotter/features/workouts/domain/repository/workout_repo.dart';
import 'package:spotter/features/workouts/domain/usecases/add_planned_exercise_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/create_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/delete_planned_exercise_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/delete_set_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/delete_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/finish_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/get_exercise_usercase.dart';
import 'package:spotter/features/workouts/domain/usecases/get_planned_exercises_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/get_sets_for_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/get_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/list_exercises_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/list_recent_workouts_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/log_set_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/start_rest_timer_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/start_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/update_planned_exercise_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/update_set_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/update_workout_usecase.dart';
import 'package:spotter/features/workouts/presentation/blocs/exercise_library_bloc/exercise_library_bloc.dart';
import 'package:spotter/features/workouts/presentation/blocs/workout_session_bloc/workout_session_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await initAuth();
  await initProfile();
  await initOnBoarding();
  await initWorkouts();
  await initNutrition();
}

Future<void> initAuth() async {
  sl.registerFactory(
    () => AuthBloc(
      deleteAccountUseCase: sl(),
      resetPasswordUseCase: sl(),
      restoreSessionUseCase: sl(),
      signInUseCase: sl(),
      signOutUseCase: sl(),
      signUpUseCase: sl(),
      verifyAccountUseCase: sl(),
      checkEmailVerifiedUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => DeleteAccountUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => RestoreSessionUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => SignInUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => SignUpUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => SignOutUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => VerifyAccountUseCase(authRepo: sl()));
  sl.registerLazySingleton(() => CheckEmailVerifiedUseCase(authRepo: sl()));

  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(authRemoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firebaseFirestore: sl(),
      googleSignIn: sl(),
    ),
  );
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton(() => firebaseAuth);
  final firebaseFirestore = FirebaseFirestore.instance;
  sl.registerLazySingleton(() => firebaseFirestore);
  await GoogleSignIn.instance.initialize();
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
}

Future<void> initProfile() async {
  sl.registerFactory(
    () => ProfileBloc(
      computeBodyMetricsUseCase: sl(),
      // updateWeeklyTargetUseCase: sl(),
      getUserProfileUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => ComputeBodyMetricsUseCase(profileRepo: sl()));
  /*  sl.registerLazySingleton(
    () => UpdateWeeklyTargetUseCase(activityTargetRepo: sl()),
  ); */
  sl.registerLazySingleton(() => GetUserProfileUseCase(profileRepo: sl()));

  sl.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(profileRemoteDataSource: sl()),
  );
  // sl.registerLazySingleton<ActivityTargetRepo>(() => ActivityTargetRepoImpl());

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firebaseFirestore: sl()),
  );
}

Future<void> initOnBoarding() async {
  sl.registerFactory(
    () => OnBoardingBloc(
      completeOnBoardingUseCase: sl(),
      computeBodyMetricsUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => CompleteOnBoardingUseCase(profileRepo: sl()));
}

Future<void> initWorkouts() async {
  sl.registerFactory(
    () => WorkoutSessionBloc(
      addPlannedExerciseUseCase: sl(),
      createWorkoutUseCase: sl(),
      deletePlannedExerciseUseCase: sl(),
      deleteSetUseCase: sl(),
      deleteWorkoutUseCase: sl(),
      finishWorkoutUseCase: sl(),
      getExerciseUseCase: sl(),
      getPlannedExercisesUseCase: sl(),
      getSetsForWorkoutUseCase: sl(),
      getWorkoutUseCase: sl(),
      listExercisesUseCase: sl(),
      listRecentWorkoutsUseCase: sl(),
      logSetUseCase: sl(),
      startRestTimerUseCase: sl(),
      startWorkoutUseCase: sl(),
      updatePlannedExerciseUseCase: sl(),
      updateSetUseCase: sl(),
      updateWorkoutUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ExerciseLibraryBloc(
      getExerciseUseCase: sl(),
      listExercisesUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => AddPlannedExerciseUseCase(plannedExerciseRepo: sl()),
  );
  sl.registerLazySingleton(() => CreateWorkoutUseCase(workoutRepo: sl()));
  sl.registerLazySingleton(
    () => DeletePlannedExerciseUseCase(plannedExerciseRepo: sl()),
  );
  sl.registerLazySingleton(() => DeleteSetUseCase(setRepo: sl()));
  sl.registerLazySingleton(() => DeleteWorkoutUseCase(workoutRepo: sl()));
  sl.registerLazySingleton(() => FinishWorkoutUseCase(workoutRepo: sl()));
  sl.registerLazySingleton(() => GetExerciseUseCase(exerciseRepo: sl()));
  sl.registerLazySingleton(
    () => GetPlannedExercisesUseCase(plannedExerciseRepo: sl()),
  );
  sl.registerLazySingleton(() => GetSetsForWorkoutUseCase(setRepo: sl()));
  sl.registerLazySingleton(() => GetWorkoutUseCase(workoutRepo: sl()));
  sl.registerLazySingleton(() => ListExercisesUseCase(exerciseRepo: sl()));
  sl.registerLazySingleton(() => ListRecentWorkoutsUseCase(workoutRepo: sl()));
  sl.registerLazySingleton(() => LogSetUseCase(setRepo: sl()));
  sl.registerLazySingleton(() => const StartRestTimerUseCase());
  sl.registerLazySingleton(() => StartWorkoutUseCase(workoutRepo: sl()));
  sl.registerLazySingleton(
    () => UpdatePlannedExerciseUseCase(plannedExerciseRepo: sl()),
  );
  sl.registerLazySingleton(() => UpdateSetUseCase(setRepo: sl()));
  sl.registerLazySingleton(() => UpdateWorkoutUseCase(workoutRepo: sl()));

  sl.registerLazySingleton<WorkoutRepo>(
    () => WorkoutRepoImpl(workoutRemoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<PlannedExerciseRepo>(
    () => PlannedExerciseRepoImpl(
      plannedExerciseRemoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<SetRepo>(
    () => SetRepoImpl(setRemoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ExerciseRepo>(
    () => ExerciseRepoImpl(exerciseRemoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<WorkoutRemoteDataSource>(
    () => WorkoutRemoteDatasourceImpl(firebaseFirestore: sl()),
  );
  sl.registerLazySingleton<PlannedExerciseRemoteDataSource>(
    () => PlannedExerciseRemoteDataSourceImpl(firebaseFirestore: sl()),
  );
  sl.registerLazySingleton<SetRemoteDataSource>(
    () => SetRemoteDataSourceImpl(firebaseFirestore: sl()),
  );
  sl.registerLazySingleton<ExerciseRemoteDataSource>(
    () => ExerciseRemoteDatasourceImpl(firebaseFirestore: sl()),
  );

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(internetConnection: sl()),
  );

  sl.registerLazySingleton(() => InternetConnection());
}

Future<void> initNutrition() async {
  // Register Food Log Bloc
  sl.registerFactory(
    () => FoodLogBloc(
      logFood: sl(),
      listMealLogsForDate: sl(),
      getDailyTotals: sl(),
      updateMealLog: sl(),
      deleteMealLog: sl(),
      repeatYesterday: sl(),
    ),
  );

  // Register Meal Plan Bloc
  sl.registerFactory(
    () => MealPlanBloc(
      createMealPlan: sl(),
      generateMealPlan: sl(),
      regenerateUnderBudget: sl(),
      saveMealPlan: sl(),
      getMealPlan: sl(),
      updateMealPlan: sl(),
      deleteMealPlan: sl(),
      listRecentMealPlans: sl(),
      addMealEntry: sl(),
    ),
  );

  // Register Use Cases for Food Log
  sl.registerLazySingleton(
    () => LogFoodUseCase(foodRepo: sl(), mealLogRepo: sl()),
  );
  sl.registerLazySingleton(() => ListMealLogsForDateUseCase(mealLogRepo: sl()));
  sl.registerLazySingleton(() => GetDailyTotalsUseCase(mealLogRepo: sl()));
  sl.registerLazySingleton(
    () => UpdateMealLogUseCase(foodRepo: sl(), mealLogRepo: sl()),
  );
  sl.registerLazySingleton(() => DeleteMealLogUseCase(mealLogRepo: sl()));
  sl.registerLazySingleton(() => RepeatYesterdayUseCase(mealLogRepo: sl()));

  // Register Use Cases for Meal Plan
  sl.registerLazySingleton(() => CreateMealPlanUseCase(mealPlanRepo: sl()));
  sl.registerLazySingleton(() => GetMealPlanUseCase(mealPlanRepo: sl()));
  sl.registerLazySingleton(
    () => ListRecentMealPlansUsecase(mealPlanRepo: sl()),
  );
  sl.registerLazySingleton(() => SaveMealPlanUsecase(mealPlanRepo: sl()));
  sl.registerLazySingleton(() => UpdateMealPlanUseCase(mealPlanRepo: sl()));
  sl.registerLazySingleton(() => DeleteMealPlanUseCase(mealPlanRepo: sl()));
  sl.registerLazySingleton(
    () => GenerateMealPlanUseCase(nutritionPrefRepo: sl()),
  );
  sl.registerLazySingleton(
    () => RegenerateUnderBudgetUseCase(nutritionPrefRepo: sl()),
  );
  sl.registerLazySingleton(() => AddMealEntryUseCase(mealEntryRepo: sl()));

  // Register Repositories
  sl.registerLazySingleton<FoodRepo>(
    () => FoodRepoImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MealLogRepo>(
    () => MealLogRepoImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MealPlanRepo>(
    () => MealPlanRepoImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MealEntryRepo>(
    () => MealEntryRepoImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NutritionPrefRepo>(
    () => NutritionPrefRepoImpl(remoteDataSource: sl()),
  );

  // Register Data Sources
  sl.registerLazySingleton<FoodRemoteDataSource>(
    () => FoodRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MealLogRemoteDataSource>(
    () => MealLogRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MealPlanRemoteDataSource>(
    () => MealPlanRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MealEntryRemoteDataSource>(
    () => MealEntryRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<NutritionPreferencesRemoteDataSource>(
    () => NutritionPreferencesRemoteDataSourceImpl(firestore: sl()),
  );
}

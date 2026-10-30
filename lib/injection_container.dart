import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    () => WorkoutRepoImpl(workoutRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<PlannedExerciseRepo>(
    () => PlannedExerciseRepoImpl(plannedExerciseRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<SetRepo>(
    () => SetRepoImpl(setRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<ExerciseRepo>(
    () => ExerciseRepoImpl(exerciseRemoteDataSource: sl()),
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
}

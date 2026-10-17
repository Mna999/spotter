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

final sl = GetIt.instance;

Future<void> init() async {
  await initAuth();
  await initProfile();
  await initOnBoarding();
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

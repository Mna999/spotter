import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/network/network_info.dart';
import 'package:spotter/features/auth/data/datasources/profile_remote_data_source.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/domain/repositories/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  ProfileRemoteDataSource profileRemoteDataSource;
  NetworkInfo networkInfo;

  ProfileRepoImpl({
    required this.profileRemoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, UserProfile>> create({
    required String uid,
    required bool isMale,
    required int age,
    required double height,
    required double weight,
    required int weeklyTargetMin,
    required ExperienceLevel experienceLevel,
    required Goal goal,
    required ActivityLevel activityLevel,
    required EquipmentAccess equipmentAccess,
    required int trainingDays,
  }) async {
    try {
      return Right(
        await profileRemoteDataSource.create(
          uid: uid,
          isMale: isMale,
          age: age,
          height: height,
          weight: weight,
          experienceLevel: experienceLevel,
          weeklyTargetMin: weeklyTargetMin,
          goal: goal,
          activityLevel: activityLevel,
          equipmentAccess: equipmentAccess,
          trainingDays: trainingDays,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> get({required String uid}) async {
    try {
      return Right(await profileRemoteDataSource.get(uid: uid));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } on OnBoardingException catch (e) {
      return const Left(
        OnBoardingFailure(
          message: 'Please finish setting up your profile to continue.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, BodyMetrics>> saveMetrics({
    required BodyMetrics metrics,
    required String uid,
  }) async {
    try {
      return Right(
        await profileRemoteDataSource.saveMetrics(metrics: metrics, uid: uid),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> update({
    required String uid,
    required bool isMale,
    required int age,
    required double height,
    required double weight,
    required ExperienceLevel experienceLevel,
    required Goal goal,
    required int weeklyTargetMin,
    required ActivityLevel activityLevel,
    required EquipmentAccess equipmentAccess,
    required int trainingDays,
  }) async {
    try {
      return Right(
        await profileRemoteDataSource.update(
          uid: uid,
          isMale: isMale,
          age: age,
          height: height,
          weight: weight,
          experienceLevel: experienceLevel,
          weeklyTargetMin: weeklyTargetMin,
          goal: goal,
          activityLevel: activityLevel,
          equipmentAccess: equipmentAccess,
          trainingDays: trainingDays,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }
}

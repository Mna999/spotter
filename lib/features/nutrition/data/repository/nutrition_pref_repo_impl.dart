import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/data/datasources/nutrition_preferences_remote_data_source.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';

class NutritionPrefRepoImpl implements NutritionPrefRepo {
  final NutritionPreferencesRemoteDataSource remoteDataSource;

  NutritionPrefRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DietaryPreferences?>> get({
    required String uid,
    required String prefsId,
  }) async {
    try {
      final prefs = await remoteDataSource.get(uid: uid, prefsId: prefsId);
      return Right(prefs);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, DietaryPreferences>> save({
    required String uid,
    required DietaryPreferences prefs,
  }) async {
    try {
      final savedPrefs = await remoteDataSource.save(uid: uid, prefs: prefs);
      return Right(savedPrefs);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, DietaryPreferences>> update({
    required String uid,
    required Map<String, dynamic> partial,
  }) async {
    try {
      final updatedPrefs = await remoteDataSource.update(
        uid: uid,
        partial: partial,
      );
      return Right(updatedPrefs);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, DietaryPreferences>> updateExclusions({
    required String uid,
    required Set<String> excludedFoodIds,
  }) async {
    try {
      final updatedPrefs = await remoteDataSource.updateExclusions(
        uid: uid,
        excludedFoodIds: excludedFoodIds,
      );
      return Right(updatedPrefs);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }
}

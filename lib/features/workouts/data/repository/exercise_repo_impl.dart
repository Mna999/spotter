import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/network/network_info.dart';
import 'package:spotter/features/workouts/data/datasources/exercise_remote_datasource.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/params/exercise_filter_params.dart';
import 'package:spotter/features/workouts/domain/repository/exercise_repo.dart';

class ExerciseRepoImpl implements ExerciseRepo {
  ExerciseRemoteDataSource exerciseRemoteDataSource;
  NetworkInfo networkInfo;

  ExerciseRepoImpl({
    required this.exerciseRemoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, Exercise?>> get({required String id}) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await exerciseRemoteDataSource.get(
          exerciseId: id,
          isLocal: !isConnected,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, List<Exercise>>> list({
    required ExerciseFilterParams filter,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await exerciseRemoteDataSource.list(
          filter: filter,
          isLocal: !isConnected,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }
}

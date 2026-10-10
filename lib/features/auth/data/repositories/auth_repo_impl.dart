import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:spotter/features/auth/domain/entities/user_account.dart';
import 'package:spotter/features/auth/domain/repositories/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRemoteDataSource authRemoteDataSource;
  AuthRepoImpl({required this.authRemoteDataSource});
  @override
  Future<Either<Failure, UserAccount?>> currentSession() async {
    return Right(await authRemoteDataSource.currentSession());
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      await authRemoteDataSource.deleteAccount();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: ExceptionHandler.authExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, UserAccount>> register(SignUpParams params) async {
    try {
      return Right(
        await authRemoteDataSource.register(
          email: params.email,
          password: params.password,
          name: params.name,
        ),
      );
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: ExceptionHandler.authExceptionHandler(e.code)),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordReset(ResetParams params) async {
    try {
      await authRemoteDataSource.sendPasswordReset(email: params.email);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: ExceptionHandler.authExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, UserAccount>> signIn(SignInParams params) async {
    try {
      return Right(
        await authRemoteDataSource.signIn(
          email: params.email,
          password: params.password,
        ),
      );
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: ExceptionHandler.authExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, UserAccount>> signInWithGoogle() async {
    try {
      return Right(await authRemoteDataSource.signInWithGoogle());
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: ExceptionHandler.authExceptionHandler(e.code)),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await authRemoteDataSource.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: ExceptionHandler.authExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailVerified() async {
    try {
      return Right(await authRemoteDataSource.checkVerified());
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: ExceptionHandler.authExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyAccount() async {
    try {
      await authRemoteDataSource.verifyAccount();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: ExceptionHandler.authExceptionHandler(e.code)),
      );
    }
  }
}

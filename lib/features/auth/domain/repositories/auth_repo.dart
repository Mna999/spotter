import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/user_account.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserAccount>> register(SignUpParams params);
  Future<Either<Failure, UserAccount>> signIn(SignInParams params);
  Future<Either<Failure, UserAccount>> signInWithGoogle();
  Future<Either<Failure, Unit>> sendPasswordReset(ResetParams params);
  Future<Either<Failure, UserAccount?>> currentSession();
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, Unit>> deleteAccount();
  Future<Either<Failure, Unit>> verifyAccount();
  Future<Either<Failure, bool>> checkEmailVerified();
}

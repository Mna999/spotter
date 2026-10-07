import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/auth/domain/entities/user_account.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserAccount>> register({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, UserAccount>> signIn({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserAccount>> signInWithGoogle();
  Future<Either<Failure, Unit>> sendPasswordReset({required String email});
  Future<Either<Failure, UserAccount?>> currentSession();
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, Unit>> deleteAccount();
}

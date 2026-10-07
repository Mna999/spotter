import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/auth/domain/entities/user_account.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserAccount>> register();
  Future<Either<Failure, UserAccount>> signIn();
}

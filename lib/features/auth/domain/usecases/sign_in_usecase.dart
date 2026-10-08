import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/user_account.dart';
import 'package:spotter/features/auth/domain/repositories/auth_repo.dart';

class SignInUseCase implements UseCase<UserAccount, SignInParams> {
  AuthRepo authRepo;
  SignInUseCase({required this.authRepo});
  @override
  Future<Either<Failure, UserAccount>> call(SignInParams params) async {
    return await authRepo.signIn(params);
  }
}

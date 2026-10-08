import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/user_account.dart';
import 'package:spotter/features/auth/domain/repositories/auth_repo.dart';

class RestoreSessionUseCase implements UseCase<UserAccount?, NoParams> {
  AuthRepo authRepo;
  RestoreSessionUseCase({required this.authRepo});

  @override
  Future<Either<Failure, UserAccount?>> call(NoParams params) async {
    return await authRepo.currentSession();
  }
}

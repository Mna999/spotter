import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/repositories/auth_repo.dart';

class CheckEmailVerifiedUseCase implements UseCase<bool, NoParams> {
  AuthRepo authRepo;
  CheckEmailVerifiedUseCase({required this.authRepo});
  @override
  Future<Either<Failure, bool>> call(NoParams) {
    return authRepo.checkEmailVerified();
  }
}

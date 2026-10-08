import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/repositories/auth_repo.dart';

class ResetPasswordUseCase implements UseCase<Unit, ResetParams> {
  AuthRepo authRepo;

  ResetPasswordUseCase({required this.authRepo});

  @override
  Future<Either<Failure, Unit>> call(ResetParams params) async {
    // TODO: implement call
    return await authRepo.sendPasswordReset(params);
  }
}

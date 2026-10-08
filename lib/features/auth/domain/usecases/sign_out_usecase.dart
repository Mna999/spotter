import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/repositories/auth_repo.dart';

class SignOutUseCase implements UseCase<Unit, NoParams> {
  AuthRepo authRepo;
  SignOutUseCase({required this.authRepo});
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await authRepo.signOut();
  }
}

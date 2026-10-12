import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/domain/repositories/profile_repo.dart';

class GetUserProfileUseCase implements UseCase<UserProfile?, ProfileParams> {
  ProfileRepo profileRepo;
  GetUserProfileUseCase({required this.profileRepo});
  @override
  Future<Either<Failure, UserProfile?>> call(ProfileParams params) {
    return profileRepo.get(params.uid);
  }
}

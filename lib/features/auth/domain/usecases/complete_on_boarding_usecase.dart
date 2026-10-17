import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/domain/repositories/profile_repo.dart';

class CompleteOnBoardingUseCase
    implements UseCase<UserProfile, OnboardingParams> {
  ProfileRepo profileRepo;
  CompleteOnBoardingUseCase({required this.profileRepo});
  @override
  Future<Either<Failure, UserProfile>> call(OnboardingParams params) async {
    return await profileRepo.create(
      uid: params.uid,
      isMale: params.isMale,
      weeklyTargetMin: params.weeklyTargetMin,
      age: params.age,
      height: params.height,
      weight: params.weight,
      experienceLevel: params.experienceLevel,
      goal: params.goal,
      activityLevel: params.activityLevel,
      equipmentAccess: params.equipmentAccess,
      trainingDays: params.trainingDays,
    );
  }
}

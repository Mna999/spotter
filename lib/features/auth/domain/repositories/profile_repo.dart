import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';

abstract class ProfileRepo {
  Future<Either<Failure, UserProfile>> create({
    required String uid,
    required bool isMale,
    required int age,
    required double height,
    required double weight,
    required int weeklyTargetMin,
    required ExperienceLevel experienceLevel,
    required Goal goal,
    required ActivityLevel activityLevel,
    required EquipmentAccess equipmentAccess,
    required int trainingDays,
  });
  Future<Either<Failure, UserProfile?>> get({required String uid});
  Future<Either<Failure, UserProfile>> update({
    required String uid,
    required bool isMale,
    required int age,
    required double height,
    required double weight,
    required int weeklyTargetMin,
    required ExperienceLevel experienceLevel,
    required Goal goal,
    required ActivityLevel activityLevel,
    required EquipmentAccess equipmentAccess,
    required int trainingDays,
  });
  Future<Either<Failure, BodyMetrics>> saveMetrics({
    required BodyMetrics metrics,
    required String uid,
  });
}

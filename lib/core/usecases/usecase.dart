import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SignInParams extends Equatable {
  String email;
  String password;
  SignInParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SignUpParams extends Equatable {
  String email;
  String password;
  String name;
  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
  @override
  List<Object?> get props => [email, password, name];
}

class ResetParams extends Equatable {
  String email;

  ResetParams({required this.email});
  @override
  List<Object?> get props => [email];
}

class TargetParams extends Equatable {
  final String uid;
  final int minutes;
  final int strengthDays;

  const TargetParams({
    required this.uid,
    required this.minutes,
    required this.strengthDays,
  });

  @override
  List<Object?> get props => [uid, minutes, strengthDays];
}

class OnboardingParams extends Equatable {
  final String uid;
  final bool isMale;
  final int age;
  final double height;
  final double weight;
  final ExperienceLevel experienceLevel;
  final Goal goal;
  final ActivityLevel activityLevel;
  final EquipmentAccess equipmentAccess;
  final int trainingDays;
  final int weeklyTargetMin;

  const OnboardingParams({
    required this.uid,
    required this.isMale,
    required this.age,
    required this.height,
    required this.weight,
    required this.experienceLevel,
    required this.goal,
    required this.activityLevel,
    required this.equipmentAccess,
    required this.trainingDays,
    required this.weeklyTargetMin,
  });

  @override
  List<Object?> get props => [
    uid,
    isMale,
    age,
    height,
    weight,
    experienceLevel,
    goal,
    activityLevel,
    equipmentAccess,
    trainingDays,
    weeklyTargetMin,
  ];
}

class MetricsParams extends Equatable {
  final String uid;
  final bool isMale;
  final int age;
  final double height;
  final double weight;
  final ActivityLevel activityLevel;
  final Goal goal;

  const MetricsParams({
    required this.uid,
    required this.isMale,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
  });

  factory MetricsParams.fromProfile(UserProfile profile) {
    return MetricsParams(
      uid: profile.uid,
      isMale: profile.isMale,
      age: profile.age,
      height: profile.height,
      weight: profile.weight,
      activityLevel: profile.activityLevel,
      goal: profile.goal,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    isMale,
    age,
    height,
    weight,
    activityLevel,
    goal,
  ];
}

class ProfileParams extends Equatable {
  final String uid;
  const ProfileParams(this.uid);

  @override
  List<Object?> get props => [uid];
}

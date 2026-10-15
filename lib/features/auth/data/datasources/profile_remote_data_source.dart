import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/auth/data/models/body_metrics_model.dart';
import 'package:spotter/features/auth/data/models/user_profile_model.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> create({
    required String uid,
    required bool isMale,
    required int age,
    required double height,
    required double weight,
    required ExperienceLevel experienceLevel,
    required int weeklyTargetMin,
    required Goal goal,
    required ActivityLevel activityLevel,
    required EquipmentAccess equipmentAccess,
    required int trainingDays,
  });

  Future<UserProfileModel> get({required String uid});

  Future<UserProfileModel> update({
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

  Future<BodyMetricsModel> saveMetrics({
    required BodyMetrics metrics,
    required String uid,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  FirebaseFirestore firebaseFirestore;
  ProfileRemoteDataSourceImpl({required this.firebaseFirestore});
  @override
  Future<UserProfileModel> create({
    required String uid,
    required bool isMale,
    required int age,
    required double height,
    required double weight,
    required ExperienceLevel experienceLevel,
    required Goal goal,
    required int weeklyTargetMin,
    required ActivityLevel activityLevel,
    required EquipmentAccess equipmentAccess,
    required int trainingDays,
  }) async {
    try {
      UserProfileModel userProfile = UserProfileModel(
        uid: uid,
        isMale: isMale,
        age: age,
        height: height,
        weight: weight,
        experienceLevel: experienceLevel,
        trainingDays: trainingDays,
        weeklyTargetMin: weeklyTargetMin,
        activityLevel: activityLevel,
        equipmentAccess: equipmentAccess,
        goal: goal,
      );
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .set(userProfile.toJson(), SetOptions(merge: true));
      return userProfile;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<UserProfileModel> get({required String uid}) async {
    try {
      final res = await firebaseFirestore.collection('users').doc(uid).get();
      final data = res.data();
      if (data == null || data['age'] == null)
        throw OnBoardingException(code: 'onboarding-not-completed');
      return UserProfileModel.fromJson(res.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<BodyMetricsModel> saveMetrics({
    required BodyMetrics metrics,
    required String uid,
  }) async {
    try {
      BodyMetricsModel bodyMetrics = BodyMetricsModel(
        bmi: metrics.bmi,
        ree: metrics.ree,
        tdee: metrics.tdee,
        macroTargets: metrics.macroTargets,
      );
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .set(bodyMetrics.toJson(), SetOptions(merge: true));
      return bodyMetrics;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<UserProfileModel> update({
    required String uid,
    required bool isMale,
    required int age,
    required double height,
    required double weight,
    required ExperienceLevel experienceLevel,
    required Goal goal,
    required int weeklyTargetMin,
    required ActivityLevel activityLevel,
    required EquipmentAccess equipmentAccess,
    required int trainingDays,
  }) async {
    try {
      UserProfileModel userProfile = UserProfileModel(
        uid: uid,
        isMale: isMale,
        age: age,
        height: height,
        weight: weight,
        experienceLevel: experienceLevel,
        trainingDays: trainingDays,
        weeklyTargetMin: weeklyTargetMin,
        activityLevel: activityLevel,
        equipmentAccess: equipmentAccess,
        goal: goal,
      );
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .update(userProfile.toJson());
      return userProfile;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

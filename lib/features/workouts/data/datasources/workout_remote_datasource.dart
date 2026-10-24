import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/workouts/data/models/workout_session_model.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';

abstract class WorkoutRemoteDataSource {
  Future<WorkoutSessionModel> save({required WorkoutSession workout});

  Future<WorkoutSessionModel> update({required WorkoutSession workout});

  Future<WorkoutSessionModel?> get({
    required String uid,
    required String workoutId,
  });

  Future<List<WorkoutSessionModel>> recent({
    required String uid,
    int limit = 20,
  });

  Future<List<WorkoutSessionModel>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  });

  Future<void> delete({required String uid, required String workoutId});
}

class WorkoutRemoteDatasourceImpl implements WorkoutRemoteDataSource {
  FirebaseFirestore firebaseFirestore;
  WorkoutRemoteDatasourceImpl({required this.firebaseFirestore});
  @override
  Future<void> delete({required String uid, required String workoutId}) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<WorkoutSessionModel?> get({
    required String uid,
    required String workoutId,
  }) async {
    try {
      final res = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .get();
      final data = res.data();
      if (data == null) return null;
      return WorkoutSessionModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<WorkoutSessionModel>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final res = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .where(
            'startedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            isLessThanOrEqualTo: Timestamp.fromDate(end),
          )
          .get();
      final data = res.docs
          .map((doc) => WorkoutSessionModel.fromJson(doc.data()))
          .toList();
      return data;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<WorkoutSessionModel>> recent({
    required String uid,
    int limit = 20,
  }) async {
    try {
      final res = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .limit(limit)
          .orderBy('createdAt')
          .get();
      final data = res.docs
          .map((doc) => WorkoutSessionModel.fromJson(doc.data()))
          .toList();
      return data;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<WorkoutSessionModel> save({required WorkoutSession workout}) async {
    try {
      WorkoutSessionModel workoutSessionModel = WorkoutSessionModel.fromEntity(
        workout,
      );
      final doc = firebaseFirestore
          .collection('users')
          .doc(workout.uid)
          .collection('workouts')
          .doc();
      workoutSessionModel.workoutId = doc.id;
      await doc.set(workoutSessionModel.toJson(isCreating: true));
      return workoutSessionModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<WorkoutSessionModel> update({required WorkoutSession workout}) async {
    try {
      WorkoutSessionModel workoutSessionModel = WorkoutSessionModel.fromEntity(
        workout,
      );
      await firebaseFirestore
          .collection('users')
          .doc(workout.uid)
          .collection('workouts')
          .doc(workout.workoutId)
          .update(workoutSessionModel.toJson());
      return workoutSessionModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

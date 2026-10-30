import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/workouts/data/models/workout_session_model.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';

abstract class WorkoutRemoteDataSource {
  Future<WorkoutSessionModel> save({
    required WorkoutSession workout,
    bool isLocal = false,
  });

  Future<WorkoutSessionModel> update({
    required WorkoutSession workout,
    bool isLocal = false,
  });

  Future<WorkoutSessionModel?> get({
    required String uid,
    required String workoutId,
    bool isLocal = false,
  });

  Future<List<WorkoutSessionModel>> recent({
    required String uid,
    int? limit,
    bool isLocal = false,
  });

  Future<List<WorkoutSessionModel>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
    bool isLocal = false,
  });

  Future<void> delete({
    required String uid,
    required String workoutId,
    bool isLocal = false,
  });
}

class WorkoutRemoteDatasourceImpl implements WorkoutRemoteDataSource {
  FirebaseFirestore firebaseFirestore;
  WorkoutRemoteDatasourceImpl({required this.firebaseFirestore});
  @override
  Future<void> delete({
    required String uid,
    required String workoutId,
    bool isLocal = false,
  }) async {
    try {
      isLocal
          ? firebaseFirestore
                .collection('users')
                .doc(uid)
                .collection('workouts')
                .doc(workoutId)
                .delete()
          : await firebaseFirestore
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
    bool isLocal = false,
  }) async {
    try {
      final res = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .get(
            GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
          );
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
    bool isLocal = false,
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
          .get(
            GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
          );
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
    int? limit,
    bool isLocal = false,
  }) async {
    try {
      Query<Map<String, dynamic>> res = firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .orderBy('createdAt');

      if (limit != null) {
        res = res.limit(limit);
      }
      final getter = await res.get(
        GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
      );
      final data = getter.docs
          .map((doc) => WorkoutSessionModel.fromJson(doc.data()))
          .toList();
      return data;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<WorkoutSessionModel> save({
    required WorkoutSession workout,
    bool isLocal = false,
  }) async {
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
      isLocal
          ? doc.set(workoutSessionModel.toJson(isCreating: true))
          : await doc.set(workoutSessionModel.toJson(isCreating: true));
      return workoutSessionModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<WorkoutSessionModel> update({
    required WorkoutSession workout,
    bool isLocal = false,
  }) async {
    try {
      WorkoutSessionModel workoutSessionModel = WorkoutSessionModel.fromEntity(
        workout,
      );
      isLocal
          ? firebaseFirestore
                .collection('users')
                .doc(workout.uid)
                .collection('workouts')
                .doc(workout.workoutId)
                .update(workoutSessionModel.toJson())
          : await firebaseFirestore
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

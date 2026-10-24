import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/workouts/data/models/planned_exercise_model.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';

abstract class PlannedExerciseRemoteDataSource {
  Future<PlannedExerciseModel> save({
    required String uid,
    required String workoutId,
    required PlannedExercise plannedExercise,
  });

  Future<PlannedExerciseModel?> get({
    required String uid,
    required String workoutId,
    required String exerciseId,
  });

  Future<List<PlannedExerciseModel>> list({
    required String uid,
    required String workoutId,
  });

  Future<PlannedExerciseModel> update({
    required PlannedExercise plannedExercise,
  });
  Future<void> delete({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  });
}

class PlannedExerciseRemoteDataSourceImpl
    implements PlannedExerciseRemoteDataSource {
  FirebaseFirestore firebaseFirestore;
  PlannedExerciseRemoteDataSourceImpl({required this.firebaseFirestore});
  @override
  Future<void> delete({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  }) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .collection('plannedExercises')
          .doc(plannedExerciseId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<PlannedExerciseModel?> get({
    required String uid,
    required String workoutId,
    required String exerciseId,
  }) async {
    try {
      final res = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .collection('plannedExercises')
          .doc(exerciseId)
          .get();
      final data = res.data();
      if (data == null) return null;
      PlannedExerciseModel plannedExerciseModel = PlannedExerciseModel.fromJson(
        data,
      );

      return plannedExerciseModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<PlannedExerciseModel>> list({
    required String uid,
    required String workoutId,
  }) async {
    try {
      final res = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .collection('plannedExercises')
          .get();
      final data = res.docs
          .map((doc) => PlannedExerciseModel.fromJson(doc.data()))
          .toList();

      return data;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<PlannedExerciseModel> save({
    required String uid,
    required String workoutId,
    required PlannedExercise plannedExercise,
  }) async {
    try {
      final doc = firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .collection('plannedExercises')
          .doc();
      PlannedExerciseModel plannedExerciseModel =
          PlannedExerciseModel.fromEntity(plannedExercise);
      plannedExerciseModel.plannedExerciseId = doc.id;
      await doc.set(plannedExerciseModel.toJson(isCreating: true));
      return plannedExerciseModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<PlannedExerciseModel> update({
    required PlannedExercise plannedExercise,
  }) async {
    try {
      PlannedExerciseModel plannedExerciseModel =
          PlannedExerciseModel.fromEntity(plannedExercise);
      await firebaseFirestore
          .collection('users')
          .doc(plannedExercise.uid)
          .collection('workouts')
          .doc(plannedExercise.workoutId)
          .collection('plannedExercises')
          .doc(plannedExercise.plannedExerciseId)
          .update(plannedExerciseModel.toJson());
      return plannedExerciseModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

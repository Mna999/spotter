import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/workouts/data/models/planned_exercise_model.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';

abstract class PlannedExerciseRemoteDataSource {
  Future<PlannedExerciseModel> save({
    required String uid,
    required String workoutId,
    required PlannedExercise plannedExercise,
    bool isLocal = false,
  });

  Future<PlannedExerciseModel?> get({
    required String uid,
    required String workoutId,
    required String exerciseId,
    bool isLocal = false,
  });

  Future<List<PlannedExerciseModel>> list({
    required String uid,
    required String workoutId,
    bool isLocal = false,
  });

  Future<PlannedExerciseModel> update({
    required PlannedExercise plannedExercise,
    bool isLocal = false,
  });
  Future<void> delete({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    bool isLocal = false,
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
    bool isLocal = false,
  }) async {
    try {
      isLocal
          ? firebaseFirestore
                .collection('users')
                .doc(uid)
                .collection('workouts')
                .doc(workoutId)
                .collection('plannedExercises')
                .doc(plannedExerciseId)
                .delete()
          : await firebaseFirestore
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
    bool isLocal = false,
  }) async {
    try {
      final res = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .collection('plannedExercises')
          .doc(exerciseId)
          .get(
            GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
          );
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
    bool isLocal = false,
  }) async {
    try {
      final res = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .collection('plannedExercises')
          .get(
            GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
          );
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
    bool isLocal = false,
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
      isLocal
          ? doc.set(plannedExerciseModel.toJson(isCreating: true))
          : await doc.set(plannedExerciseModel.toJson(isCreating: true));
      return plannedExerciseModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<PlannedExerciseModel> update({
    required PlannedExercise plannedExercise,
    bool isLocal = false,
  }) async {
    try {
      PlannedExerciseModel plannedExerciseModel =
          PlannedExerciseModel.fromEntity(plannedExercise);
      isLocal
          ? firebaseFirestore
                .collection('users')
                .doc(plannedExercise.uid)
                .collection('workouts')
                .doc(plannedExercise.workoutId)
                .collection('plannedExercises')
                .doc(plannedExercise.plannedExerciseId)
                .update(plannedExerciseModel.toJson())
          : await firebaseFirestore
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

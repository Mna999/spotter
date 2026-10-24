import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/workouts/data/models/set_summary_model.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';

abstract class SetRemoteDataSource {
  Future<SetSummaryModel> saveSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required SetSummary setSummary,
  });

  Future<List<SetSummaryModel>> getSetsFor({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  });
  Future<void> deleteSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required String setId,
  });

  Future<SetSummaryModel> update({required SetSummary setSummary});
}


class SetRemoteDataSourceImpl implements SetRemoteDataSource {
  FirebaseFirestore firebaseFirestore;
  SetRemoteDataSourceImpl({required this.firebaseFirestore});

  CollectionReference<Map<String, dynamic>> _setsRef({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  }) => firebaseFirestore
      .collection('users')
      .doc(uid)
      .collection('workouts')
      .doc(workoutId)
      .collection('plannedExercises')
      .doc(plannedExerciseId)
      .collection('sets');

  @override
  Future<void> deleteSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required String setId,
  }) async {
    try {
      await _setsRef(
        uid: uid,
        workoutId: workoutId,
        plannedExerciseId: plannedExerciseId,
      ).doc(setId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<SetSummaryModel>> getSetsFor({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  }) async {
    try {
      final res = await _setsRef(
        uid: uid,
        workoutId: workoutId,
        plannedExerciseId: plannedExerciseId,
      ).get();
      final data = res.docs
          .map((doc) => SetSummaryModel.fromJson(doc.data()))
          .toList();
      return data;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<SetSummaryModel> saveSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required SetSummary setSummary,
  }) async {
    try {
      SetSummaryModel setSummaryModel = SetSummaryModel.fromEntity(setSummary);
      final doc = _setsRef(
        uid: uid,
        workoutId: workoutId,
        plannedExerciseId: plannedExerciseId,
      ).doc();
      setSummaryModel.setId = doc.id;
      await doc.set(setSummaryModel.toJson(isCreating: true));
      return setSummaryModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<SetSummaryModel> update({required SetSummary setSummary}) async {
    try {
      SetSummaryModel setSummaryModel = SetSummaryModel.fromEntity(setSummary);
      await _setsRef(
        uid: setSummary.uid,
        workoutId: setSummary.workoutId,
        plannedExerciseId: setSummary.plannedExerciseId,
      ).doc(setSummary.setId).update(setSummaryModel.toJson());
      return setSummaryModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

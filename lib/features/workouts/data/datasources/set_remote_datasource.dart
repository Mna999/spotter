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
    bool isLocal = false,
  });

  Future<List<SetSummaryModel>> getSetsFor({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    bool isLocal = false,
  });
  Future<void> deleteSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required String setId,
    bool isLocal = false,
  });

  Future<SetSummaryModel> update({
    required SetSummary setSummary,
    bool isLocal = false,
  });
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
    bool isLocal = false,
  }) async {
    try {
      isLocal
          ? _setsRef(
              uid: uid,
              workoutId: workoutId,
              plannedExerciseId: plannedExerciseId,
            ).doc(setId).delete()
          : await _setsRef(
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
    bool isLocal = false,
  }) async {
    try {
      final res = await _setsRef(
        uid: uid,
        workoutId: workoutId,
        plannedExerciseId: plannedExerciseId,
      ).get(GetOptions(source: isLocal ? Source.cache : Source.serverAndCache));
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
    bool isLocal = false,
  }) async {
    try {
      SetSummaryModel setSummaryModel = SetSummaryModel.fromEntity(setSummary);
      final doc = _setsRef(
        uid: uid,
        workoutId: workoutId,
        plannedExerciseId: plannedExerciseId,
      ).doc();
      setSummaryModel.setId = doc.id;
      isLocal
          ? doc.set(setSummaryModel.toJson(isCreating: true))
          : await doc.set(setSummaryModel.toJson(isCreating: true));
      return setSummaryModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<SetSummaryModel> update({
    required SetSummary setSummary,
    bool isLocal = false,
  }) async {
    try {
      SetSummaryModel setSummaryModel = SetSummaryModel.fromEntity(setSummary);
      isLocal
          ? _setsRef(
              uid: setSummary.uid,
              workoutId: setSummary.workoutId,
              plannedExerciseId: setSummary.plannedExerciseId,
            ).doc(setSummary.setId).update(setSummaryModel.toJson())
          : await _setsRef(
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

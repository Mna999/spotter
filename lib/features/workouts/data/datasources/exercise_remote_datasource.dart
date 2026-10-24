import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/workouts/data/models/exercise_model.dart';
import 'package:spotter/features/workouts/domain/params/exercise_filter_params.dart';

abstract class ExerciseRemoteDataSource {
  Future<List<ExerciseModel>> list({required ExerciseFilterParams filter});
  Future<ExerciseModel?> get({required String exerciseId});
}

class ExerciseRemoteDatasourceImpl implements ExerciseRemoteDataSource {
  FirebaseFirestore firebaseFirestore;

  ExerciseRemoteDatasourceImpl({required this.firebaseFirestore});

  @override
  Future<ExerciseModel?> get({required String exerciseId}) async {
    try {
      final res = await firebaseFirestore
          .collection('exercises')
          .doc(exerciseId)
          .get();
      final data = res.data();
      if (data == null) return null;
      ExerciseModel exerciseModel = ExerciseModel.fromJson(data);
      return exerciseModel;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<ExerciseModel>> list({
    required ExerciseFilterParams filter,
  }) async {
    try {
      final query = filter.query;
      if (query == null) return [];
      Query res = firebaseFirestore
          .collection('exercises')
          .where(
            Filter.or(
              Filter(
                'nameLowerEn',
                isGreaterThanOrEqualTo: query.toLowerCase(),
                isLessThan: '${query.toLowerCase()}\u{F8FF}',
              ),
              Filter(
                'nameLowerAr',
                isGreaterThanOrEqualTo: query.toLowerCase(),
                isLessThan: '${query.toLowerCase()}\u{F8FF}',
              ),
            ),
          )
          .limit(filter.limit);

      if (filter.cursor != null) {
        final cursorDoc = await firebaseFirestore
            .collection('exercises')
            .doc(filter.cursor)
            .get();
        if (cursorDoc.exists) {
          res = res.startAfterDocument(cursorDoc);
        }
      }

      QuerySnapshot<Object?> data = await res.get();

      return data.docs
          .map(
            (doc) => ExerciseModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

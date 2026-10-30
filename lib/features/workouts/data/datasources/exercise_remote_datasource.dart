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
      return ExerciseModel.fromJson(data, documentId: exerciseId);
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<ExerciseModel>> list({
    required ExerciseFilterParams filter,
  }) async {
    try {
      final collection = firebaseFirestore.collection('exercises');
      final query = filter.query?.trim().toLowerCase();
      final limit = filter.limit;

      if (query == null || query.isEmpty) {
        // No search term: read the whole catalogue straight from Firestore so
        // the picker can list every exercise before the user types anything.
        final snapshot = limit > 0
            ? await collection.limit(limit).get()
            : await collection.get();
        return _sorted(snapshot.docs.map(_toModel));
      }

      // Case-insensitive prefix search, executed by Firestore.
      // Each name field needs its own range query: a Filter takes exactly one
      // operator, and a single range query cannot span two different fields.
      final upperBound = '$query\u{F8FF}';
      final snapshots = await Future.wait([
        _prefixQuery(collection, 'nameLowerEn', query, upperBound, limit),
        _prefixQuery(collection, 'nameLowerAr', query, upperBound, limit),
      ]);

      final byId = <String, ExerciseModel>{};
      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          final model = _toModel(doc);
          byId[model.exerciseId] = model;
        }
      }

      final models = _sorted(byId.values);
      return limit > 0 && models.length > limit
          ? models.sublist(0, limit)
          : models;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _prefixQuery(
    CollectionReference<Map<String, dynamic>> collection,
    String field,
    String prefix,
    String upperBound,
    int limit,
  ) {
    Query<Map<String, dynamic>> query = collection
        .where(field, isGreaterThanOrEqualTo: prefix)
        .where(field, isLessThan: upperBound);
    if (limit > 0) query = query.limit(limit);
    return query.get();
  }

  ExerciseModel _toModel(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return ExerciseModel.fromJson(doc.data(), documentId: doc.id);
  }

  /// Merging the English and Arabic result sets produces an unsorted list, so
  /// it is ordered by English name before it reaches the UI.
  List<ExerciseModel> _sorted(Iterable<ExerciseModel> models) {
    return models.toList()..sort(
      (a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()),
    );
  }
}

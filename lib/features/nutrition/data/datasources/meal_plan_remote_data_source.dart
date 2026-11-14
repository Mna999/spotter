import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/firestore_local_write.dart';
import 'package:spotter/core/firestore_recursive_delete.dart';
import 'package:spotter/features/nutrition/data/models/meal_plan_model.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';

abstract class MealPlanRemoteDataSource {
  /// Create or overwrite a meal plan
  Future<MealPlan> save({
    required String uid,
    required MealPlan plan,
    bool isLocal = false,
  });

  /// Get a meal plan by ID
  Future<MealPlan?> get({
    required String uid,
    required String mealPlanId,
    bool isLocal = false,
  });

  /// Get recent meal plans (most recent first)
  Future<List<MealPlan>> recent({
    required String uid,
    int limit = 20,
    String? cursor,
    bool isLocal = false,
  });

  /// Get meal plans within a date range
  Future<List<MealPlan>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
    bool isLocal = false,
  });

  /// Update partial meal plan fields
  Future<MealPlan> update({
    required String uid,
    required String mealPlanId,
    required Map<String, dynamic> partial,
    bool isLocal = false,
  });

  /// Delete a meal plan
  Future<void> delete({
    required String uid,
    required String mealPlanId,
    bool isLocal = false,
  });
}

class MealPlanRemoteDataSourceImpl implements MealPlanRemoteDataSource {
  FirebaseFirestore firebaseFirestore;

  MealPlanRemoteDataSourceImpl({required this.firebaseFirestore});

  CollectionReference<Map<String, dynamic>> _plansRef({required String uid}) =>
      firebaseFirestore.collection('users').doc(uid).collection('mealPlans');

  @override
  Future<void> delete({
    required String uid,
    required String mealPlanId,
    bool isLocal = false,
  }) async {
    try {
      final docRef = _plansRef(uid: uid).doc(mealPlanId);
      if (!isLocal) {
        // Also removes the plan's entries subcollection.
        await deleteDocumentRecursively(
          docRef,
          subcollectionPaths: ['entries'],
        );
        return;
      }

      // Subcollections cannot be listed from the offline cache, so queue the
      // deletion of every entry that is cached and then remove the plan
      // itself. Entries that were never cached stay unreachable under the
      // deleted plan and cannot be removed while offline.
      try {
        final cachedEntries = await docRef
            .collection('entries')
            .get(const GetOptions(source: Source.cache));
        for (final entry in cachedEntries.docs) {
          unawaited(entry.reference.delete().catchError((Object _) {}));
        }
      } on FirebaseException {
        // The entries were never cached: nothing else can be queued here.
      }
      await applyFirestoreWrite(
        docRef.delete(),
        document: docRef,
        isLocal: true,
        isApplied: (snapshot) => !snapshot.exists,
      );
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealPlan?> get({
    required String uid,
    required String mealPlanId,
    bool isLocal = false,
  }) async {
    try {
      final doc = await _plansRef(uid: uid)
          .doc(mealPlanId)
          .get(
            GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
          );
      final data = doc.data();
      if (data == null || data.isEmpty) return null;
      final model = MealPlanModel.fromJson(data, docId: doc.id);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<MealPlan>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
    bool isLocal = false,
  }) async {
    try {
      final snapshot = await _plansRef(uid: uid)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .orderBy('date', descending: true)
          .get(
            GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
          );

      return snapshot.docs
          .map((doc) => MealPlanModel.fromJson(doc.data(), docId: doc.id))
          .map((model) => model.toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<MealPlan>> recent({
    required String uid,
    int limit = 20,
    String? cursor,
    bool isLocal = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _plansRef(
        uid: uid,
      ).orderBy('createdAt', descending: true).limit(limit);

      // Apply pagination if cursor is provided
      if (cursor != null) {
        final lastDoc = await _plansRef(uid: uid)
            .doc(cursor)
            .get(
              GetOptions(
                source: isLocal ? Source.cache : Source.serverAndCache,
              ),
            );

        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get(
        GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
      );
      return snapshot.docs
          .map((doc) => MealPlanModel.fromJson(doc.data(), docId: doc.id))
          .map((model) => model.toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealPlan> save({
    required String uid,
    required MealPlan plan,
    bool isLocal = false,
  }) async {
    try {
      final collection = _plansRef(uid: uid);
      // New plans arrive with an empty id; let Firestore assign one.
      final docRef = plan.mealPlanId.trim().isEmpty
          ? collection.doc()
          : collection.doc(plan.mealPlanId);
      final model = MealPlanModel.fromEntity(plan).withId(docRef.id);

      await applyFirestoreWrite(
        docRef.set(model.toJson()),
        document: docRef,
        isLocal: isLocal,
      );

      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealPlan> update({
    required String uid,
    required String mealPlanId,
    required Map<String, dynamic> partial,
    bool isLocal = false,
  }) async {
    try {
      final docRef = _plansRef(uid: uid).doc(mealPlanId);

      // Add timestamp for update
      partial['updatedAt'] = FieldValue.serverTimestamp();

      await applyFirestoreWrite(
        docRef.update(partial),
        document: docRef,
        isLocal: isLocal,
      );

      // Get updated document
      final doc = await docRef.get(
        GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
      );
      final model = MealPlanModel.fromJson(doc.data()!, docId: doc.id);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

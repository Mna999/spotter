import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/firestore_recursive_delete.dart';
import 'package:spotter/features/nutrition/data/models/meal_plan_model.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';

abstract class MealPlanRemoteDataSource {
  /// Create or overwrite a meal plan
  Future<MealPlan> save({required String uid, required MealPlan plan});

  /// Get a meal plan by ID
  Future<MealPlan?> get({required String uid, required String mealPlanId});

  /// Get recent meal plans (most recent first)
  Future<List<MealPlan>> recent({
    required String uid,
    int limit = 20,
    String? cursor,
  });

  /// Get meal plans within a date range
  Future<List<MealPlan>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  });

  /// Update partial meal plan fields
  Future<MealPlan> update({
    required String uid,
    required String mealPlanId,
    required Map<String, dynamic> partial,
  });

  /// Delete a meal plan
  Future<void> delete({required String uid, required String mealPlanId});
}

class MealPlanRemoteDataSourceImpl implements MealPlanRemoteDataSource {
  FirebaseFirestore firebaseFirestore;

  MealPlanRemoteDataSourceImpl({required this.firebaseFirestore});

  CollectionReference<Map<String, dynamic>> _plansRef({required String uid}) =>
      firebaseFirestore.collection('users').doc(uid).collection('mealPlans');

  @override
  Future<void> delete({required String uid, required String mealPlanId}) async {
    try {
      // Also removes the plan's entries subcollection.
      await deleteDocumentRecursively(
        _plansRef(uid: uid).doc(mealPlanId),
        subcollectionPaths: ['entries'],
      );
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealPlan?> get({
    required String uid,
    required String mealPlanId,
  }) async {
    try {
      final doc = await _plansRef(uid: uid).doc(mealPlanId).get();
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
  }) async {
    try {
      final snapshot = await _plansRef(uid: uid)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .orderBy('date', descending: true)
          .get();

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
  }) async {
    try {
      Query<Map<String, dynamic>> query = _plansRef(
        uid: uid,
      ).orderBy('createdAt', descending: true).limit(limit);

      // Apply pagination if cursor is provided
      if (cursor != null) {
        final lastDoc = await _plansRef(uid: uid).doc(cursor).get();

        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => MealPlanModel.fromJson(doc.data(), docId: doc.id))
          .map((model) => model.toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealPlan> save({required String uid, required MealPlan plan}) async {
    try {
      final collection = _plansRef(uid: uid);
      // New plans arrive with an empty id; let Firestore assign one.
      final docRef = plan.mealPlanId.trim().isEmpty
          ? collection.doc()
          : collection.doc(plan.mealPlanId);
      final model = MealPlanModel.fromEntity(plan).withId(docRef.id);

      await docRef.set(model.toJson());

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
  }) async {
    try {
      final docRef = _plansRef(uid: uid).doc(mealPlanId);

      // Add timestamp for update
      partial['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.update(partial);

      // Get updated document
      final doc = await docRef.get();
      final model = MealPlanModel.fromJson(doc.data()!, docId: doc.id);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

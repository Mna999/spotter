import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/nutrition/data/models/meal_entry_model.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';

abstract class MealEntryRemoteDataSource {
  /// Save a meal entry
  Future<MealEntry> save({
    required String uid,
    required String mealPlanId,
    required MealEntry entry,
  });

  /// Get a meal entry by ID
  Future<MealEntry?> get({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  });

  /// List all entries for a meal plan
  Future<List<MealEntry>> list({
    required String uid,
    required String mealPlanId,
  });

  /// Update partial meal entry fields
  Future<MealEntry> update({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    required Map<String, dynamic> partial,
  });

  /// Delete a meal entry
  Future<void> delete({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  });
}

class MealEntryRemoteDataSourceImpl implements MealEntryRemoteDataSource {
  final FirebaseFirestore _firestore;

  MealEntryRemoteDataSourceImpl({required this._firestore});

  @override
  Future<void> delete({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  }) async {
    try {
      await _firestore
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('entries')
          .doc(mealEntryId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealEntry?> get({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  }) async {
    try {
      final doc = await _firestore
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('entries')
          .doc(mealEntryId)
          .get();
      final data = doc.data();
      if (data == null || data.isEmpty) {
        return null;
      }

      final model = MealEntryModel.fromJson(data, docId: doc.id);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<MealEntry>> list({
    required String uid,
    required String mealPlanId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('entries')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => MealEntryModel.fromJson(doc.data(), docId: doc.id))
          .map((model) => model.toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealEntry> save({
    required String uid,
    required String mealPlanId,
    required MealEntry entry,
  }) async {
    try {
      final collection = _firestore
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('entries');
      // New entries arrive with an empty id; let Firestore assign one.
      final docRef = entry.mealEntryId.trim().isEmpty
          ? collection.doc()
          : collection.doc(entry.mealEntryId);
      final model = MealEntryModel.fromEntity(entry).withId(docRef.id);

      await docRef.set(model.toJson());

      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealEntry> update({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    required Map<String, dynamic> partial,
  }) async {
    try {
      final docRef = _firestore
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('entries')
          .doc(mealEntryId);

      // Add timestamp for update
      partial['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.update(partial);

      // Get updated document
      final doc = await docRef.get();
      final model = MealEntryModel.fromJson(doc.data()!, docId: doc.id);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

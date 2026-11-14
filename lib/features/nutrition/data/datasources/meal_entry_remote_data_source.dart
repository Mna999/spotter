import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/firestore_local_write.dart';
import 'package:spotter/features/nutrition/data/models/meal_entry_model.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';

abstract class MealEntryRemoteDataSource {
  /// Save a meal entry
  Future<MealEntry> save({
    required String uid,
    required String mealPlanId,
    required MealEntry entry,
    bool isLocal = false,
  });

  /// Get a meal entry by ID
  Future<MealEntry?> get({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    bool isLocal = false,
  });

  /// List all entries for a meal plan
  Future<List<MealEntry>> list({
    required String uid,
    required String mealPlanId,
    bool isLocal = false,
  });

  /// Update partial meal entry fields
  Future<MealEntry> update({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    required Map<String, dynamic> partial,
    bool isLocal = false,
  });

  /// Delete a meal entry
  Future<void> delete({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    bool isLocal = false,
  });
}

class MealEntryRemoteDataSourceImpl implements MealEntryRemoteDataSource {
  FirebaseFirestore firebaseFirestore;

  MealEntryRemoteDataSourceImpl({required this.firebaseFirestore});

  CollectionReference<Map<String, dynamic>> _entriesRef({
    required String uid,
    required String mealPlanId,
  }) => firebaseFirestore
      .collection('users')
      .doc(uid)
      .collection('mealPlans')
      .doc(mealPlanId)
      .collection('entries');

  @override
  Future<void> delete({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    bool isLocal = false,
  }) async {
    try {
      final docRef = _entriesRef(
        uid: uid,
        mealPlanId: mealPlanId,
      ).doc(mealEntryId);
      await applyFirestoreWrite(
        docRef.delete(),
        document: docRef,
        isLocal: isLocal,
        isApplied: (snapshot) => !snapshot.exists,
      );
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealEntry?> get({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    bool isLocal = false,
  }) async {
    try {
      final doc = await _entriesRef(uid: uid, mealPlanId: mealPlanId)
          .doc(mealEntryId)
          .get(
            GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
          );
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
    bool isLocal = false,
  }) async {
    try {
      // Entries are scoped by the `users/{uid}/mealPlans/{planId}/entries`
      // path, so no uid filter is needed. Ordering is done in memory.
      final snapshot = await _entriesRef(
        uid: uid,
        mealPlanId: mealPlanId,
      ).get(GetOptions(source: isLocal ? Source.cache : Source.server));

      final entries = snapshot.docs
          .map((doc) => MealEntryModel.fromJson(doc.data(), docId: doc.id))
          .map((model) => model.toEntity())
          .toList();

      entries.sort((a, b) => a.order.compareTo(b.order));
      return entries;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealEntry> save({
    required String uid,
    required String mealPlanId,
    required MealEntry entry,
    bool isLocal = false,
  }) async {
    try {
      final collection = _entriesRef(uid: uid, mealPlanId: mealPlanId);
      // New entries arrive with an empty id; let Firestore assign one.
      final docRef = entry.mealEntryId.trim().isEmpty
          ? collection.doc()
          : collection.doc(entry.mealEntryId);
      final model = MealEntryModel.fromEntity(entry).withId(docRef.id);

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
  Future<MealEntry> update({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    required Map<String, dynamic> partial,
    bool isLocal = false,
  }) async {
    try {
      final docRef = _entriesRef(
        uid: uid,
        mealPlanId: mealPlanId,
      ).doc(mealEntryId);

      // Add timestamp for update
      partial['updatedAt'] = FieldValue.serverTimestamp();

      await applyFirestoreWrite(
        docRef.update(partial),
        document: docRef,
        isLocal: isLocal,
      );

      // Get updated document
      final doc = await docRef.get(
        GetOptions(source: isLocal ? Source.cache : Source.server),
      );
      final model = MealEntryModel.fromJson(doc.data()!, docId: doc.id);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}

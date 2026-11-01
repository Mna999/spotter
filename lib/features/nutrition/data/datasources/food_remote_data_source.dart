import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/nutrition/data/models/food_item_model.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/params/food_filter_params.dart';

abstract class FoodRemoteDataSource {
  /// Search for food items by query (cursor = last document id).
  Future<List<FoodItem>> search({
    required String query,
    int limit = 20,
    String? cursor,
  });

  /// Get a food item by ID
  Future<FoodItem?> getById({required String foodId});

  /// List food items with optional filtering
  Future<List<FoodItem>> list({required FoodFilterParams filter});
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final FirebaseFirestore _firestore;

  FoodRemoteDataSourceImpl({required this._firestore});

  @override
  Future<FoodItem?> getById({required String foodId}) async {
    try {
      final doc = await _firestore.collection('foods').doc(foodId).get();

      final data = doc.data();
      if (data == null || data.isEmpty) return null;

      final model = FoodItemModel.fromJson(doc.data()!, docId: doc.id);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<FoodItem>> list({required FoodFilterParams filter}) async {
    try {
      // Order first, then paginate from the last document of the previous
      // page. Using the document snapshot (instead of a raw value) keeps
      // pagination correct even when several foods share the same name.
      Query<Map<String, dynamic>> query = _firestore
          .collection('foods')
          .orderBy('nameEn');

      if (filter.category != null) {
        query = query.where('category', isEqualTo: filter.category);
      }

      if (filter.cursor != null && filter.cursor!.trim().isNotEmpty) {
        final cursorDoc = await _firestore
            .collection('foods')
            .doc(filter.cursor)
            .get();
        if (cursorDoc.exists) {
          query = query.startAfterDocument(cursorDoc);
        }
      }

      final snapshot = await query.limit(filter.limit).get();
      return snapshot.docs
          .map((doc) => FoodItemModel.fromJson(doc.data(), docId: doc.id))
          .map((model) => model.toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<FoodItem>> search({
    required String query,
    int limit = 20,
    String? cursor,
  }) async {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    List<FoodItem> prefixMatches = const [];

    try {
      // Preferred path: prefix match on the denormalized lowercase
      // `searchText` field, paged from the last document of the previous page.
      Query<Map<String, dynamic>> request = _firestore
          .collection('foods')
          .where('searchText', isGreaterThanOrEqualTo: needle)
          .where('searchText', isLessThanOrEqualTo: '$needle\uf8ff')
          .orderBy('searchText');

      if (cursor != null && cursor.trim().isNotEmpty) {
        final cursorDoc = await _firestore
            .collection('foods')
            .doc(cursor)
            .get();
        if (cursorDoc.exists) {
          request = request.startAfterDocument(cursorDoc);
        }
      }

      prefixMatches = _toFoods(await request.limit(limit).get());
    } on FirebaseException catch (e) {
      // Auth/network problems must not be hidden by the in-memory fallback.
      if (e.code == 'permission-denied' ||
          e.code == 'unauthenticated' ||
          e.code == 'unavailable' ||
          e.code == 'deadline-exceeded') {
        throw ServerException(code: e.code);
      }
    }

    if (prefixMatches.isNotEmpty) return prefixMatches;
    // There is no next page when we already paged past the first one.
    if (cursor != null && cursor.trim().isNotEmpty) return const [];

    try {
      // Fallback: older catalogues store `searchText` as a token list (or not
      // at all), which the range query above cannot match. Filter a page of
      // the catalogue in memory so search still returns results.
      final page = await _firestore
          .collection('foods')
          .orderBy('nameEn')
          .limit(500)
          .get();

      return _toFoods(page).where((food) => _matches(food, needle)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  List<FoodItem> _toFoods(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => FoodItemModel.fromJson(doc.data(), docId: doc.id))
        .map((model) => model.toEntity())
        .toList();
  }

  bool _matches(FoodItem food, String needle) {
    return food.searchText.contains(needle) ||
        food.nameEn.toLowerCase().contains(needle) ||
        (food.nameAr?.toLowerCase().contains(needle) ?? false) ||
        food.aliases.any((alias) => alias.toLowerCase().contains(needle));
  }
}

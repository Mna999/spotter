import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/nutrition/data/models/food_item_model.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/params/food_filter_params.dart';

abstract class FoodRemoteDataSource {
  /// Search for food items by query
  Future<List<FoodItem>> search({required String query});

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
      Query<Map<String, dynamic>> query = _firestore.collection('foods');

      if (filter.category != null) {
        query = query.where('category', isEqualTo: filter.category);
      }

      // Apply pagination if cursor is provided
      if (filter.cursor != null) {
        query = query.startAfter([filter.cursor]).limit(filter.limit);
      } else {
        query = query.limit(filter.limit);
      }

      // Order by name for consistent results
      query = query.orderBy('nameEn');

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FoodItemModel.fromJson(doc.data(), docId: doc.id))
          .map((model) => model.toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<FoodItem>> search({required String query}) async {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    try {
      // Preferred path: prefix match on the denormalized lowercase
      // `searchText` field.
      final snapshot = await _firestore
          .collection('foods')
          .where('searchText', isGreaterThanOrEqualTo: needle)
          .where('searchText', isLessThanOrEqualTo: '$needle\uf8ff')
          .limit(20)
          .get();

      final prefixMatches = _toFoods(snapshot);
      if (prefixMatches.isNotEmpty) return prefixMatches;

      // Fallback: older catalogues store `searchText` as a token list (or not
      // at all), which the range query above cannot match. Filter a page of
      // the catalogue in memory so search still returns results.
      final page = await _firestore
          .collection('foods')
          .orderBy('nameEn')
          .limit(200)
          .get();

      return _toFoods(
        page,
      ).where((food) => _matches(food, needle)).take(20).toList();
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

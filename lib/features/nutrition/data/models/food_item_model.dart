import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/data/models/macro_nutrients_model.dart';
import 'package:spotter/features/nutrition/data/models/portion_model.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/entities/price_basis.dart';

class FoodItemModel extends FoodItem {
  FoodItemModel({
    required super.foodId,
    required super.nameEn,
    super.nameAr,
    super.aliases = const <String>[],
    required super.category,
    required super.per100g,
    super.portions = const <Portion>[],
    super.priceEgp,
    required super.priceBasis,
    super.priceAsOf,
    required super.schemaVersion,
    required super.updatedAt,
    required super.createdAt,
    required super.searchText,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'aliases': aliases,
      'category': category,
      'per100g': MacroNutrientsModel.fromEntity(per100g).toJson(),
      'portions': portions.map((p) => PortionModel.fromEntity(p).toJson()).toList(),
      'priceEgp': priceEgp,
      'priceBasis': priceBasis.toString(),
      'priceAsOf': priceAsOf != null ? Timestamp.fromDate(priceAsOf!) : null,
      'schemaVersion': schemaVersion,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'searchText': searchText,
    };
  }

  // Create model from JSON (Firestore document)
  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      foodId: json['foodId'],
      nameEn: json['nameEn'],
      nameAr: json['nameAr'],
      aliases: List<String>.from(json['aliases'] ?? []),
      category: json['category'],
      per100g: MacroNutrientsModel.fromJson(json['per100g']).toEntity(),
      portions: (json['portions'] as List)
          .map((p) => PortionModel.fromJson(p).toEntity())
          .toList(),
      priceEgp: json['priceEgp']?.toDouble(),
      priceBasis: PriceBasis.fromString(json['priceBasis']),
      priceAsOf: json['priceAsOf'] != null 
          ? (json['priceAsOf'] as Timestamp).toDate() 
          : null,
      schemaVersion: json['schemaVersion'],
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      searchText: json['searchText'],
    );
  }

  // Create model from domain entity
  factory FoodItemModel.fromEntity(FoodItem entity) {
    return FoodItemModel(
      foodId: entity.foodId,
      nameEn: entity.nameEn,
      nameAr: entity.nameAr,
      aliases: entity.aliases,
      category: entity.category,
      per100g: entity.per100g,
      portions: entity.portions,
      priceEgp: entity.priceEgp,
      priceBasis: entity.priceBasis,
      priceAsOf: entity.priceAsOf,
      schemaVersion: entity.schemaVersion,
      updatedAt: entity.updatedAt,
      createdAt: entity.createdAt,
      searchText: entity.searchText,
    );
  }

  // Convert to domain entity
  FoodItem toEntity() {
    return FoodItem(
      foodId: foodId,
      nameEn: nameEn,
      nameAr: nameAr,
      aliases: aliases,
      category: category,
      per100g: per100g,
      portions: portions,
      priceEgp: priceEgp,
      priceBasis: priceBasis,
      priceAsOf: priceAsOf,
      schemaVersion: schemaVersion,
      updatedAt: updatedAt,
      createdAt: createdAt,
      searchText: searchText,
    );
  }
}
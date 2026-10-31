import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/input_converter/input_parser.dart';
import 'package:spotter/features/nutrition/data/models/macro_nutrients_model.dart';
import 'package:spotter/features/nutrition/data/models/portion_model.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/entities/price_basis.dart';

class FoodItemModel extends FoodItem {
  const FoodItemModel({
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
      'portions': portions
          .map((p) => PortionModel.fromEntity(p).toJson())
          .toList(),
      'priceEgp': priceEgp,
      'priceBasis': priceBasis.name,
      'priceAsOf': priceAsOf != null ? Timestamp.fromDate(priceAsOf!) : null,
      'schemaVersion': schemaVersion,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'searchText': searchText,
    };
  }

  // Create model from JSON (Firestore document). [docId] is the document id,
  // which is the source of truth when the stored body predates that field.
  factory FoodItemModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return FoodItemModel(
      foodId: docId ?? json['foodId'] ?? '',
      nameEn: json['nameEn'] ?? '',
      nameAr: json['nameAr'],
      aliases: List<String>.from(json['aliases'] ?? []),
      category: json['category'] ?? '',
      per100g: MacroNutrientsModel.fromJson(json['per100g']).toEntity(),
      portions: ((json['portions'] as List?) ?? const [])
          .map((p) => PortionModel.fromJson(p).toEntity())
          .toList(),
      priceEgp: (json['priceEgp'] as num?)?.toDouble(),
      priceBasis: PriceBasis.fromString(json['priceBasis'] ?? 'weight'),
      priceAsOf:
          InputParser.toDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? SCHEMA_VERSION,
      createdAt:
          InputParser.toDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          InputParser.toDateTime(json['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      searchText: _searchText(json),
    );
  }

  /// Firestore documents seeded by different scripts store `searchText` either
  /// as a lowercase string or as a list of tokens (the original search query
  /// used `arrayContains`). Normalize both shapes to one searchable string so
  /// parsing never throws and client-side matching still works.
  static String _searchText(Map<String, dynamic> json) {
    final raw = json['searchText'];
    if (raw is String && raw.trim().isNotEmpty) return raw.toLowerCase();
    if (raw is Iterable) {
      return raw
          .map((token) => token.toString().toLowerCase())
          .join(' ')
          .trim();
    }
    return <String>[
      if (json['nameEn'] != null) json['nameEn'].toString(),
      if (json['nameAr'] != null) json['nameAr'].toString(),
      ...List<String>.from(json['aliases'] ?? <String>[]),
      if (json['category'] != null) json['category'].toString(),
    ].join(' ').toLowerCase();
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

import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/entities/price_basis.dart';

class FoodItem extends Equatable {
  final String foodId;
  final String nameEn;
  final String? nameAr;
  final List<String> aliases;
  final String category;
  final MacroNutrients per100g;
  final List<Portion> portions;
  final double? priceEgp;
  final PriceBasis priceBasis;
  final DateTime? priceAsOf;
  final int schemaVersion;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String searchText;

  const FoodItem({
    required this.foodId,
    required this.nameEn,
    this.nameAr,
    this.aliases = const <String>[],
    required this.category,
    required this.per100g,
    this.portions = const <Portion>[],
    this.priceEgp,
    required this.priceBasis,
    this.priceAsOf,
    required this.schemaVersion,
    required this.updatedAt,
    required this.createdAt,
    required this.searchText,
  });

  /// FR-NUT-03: an indicative EGP price older than 90 days is stale.
  bool get isPriceStale {
    final asOf = priceAsOf;
    if (asOf == null) return priceEgp != null;
    return DateTime.now().difference(asOf).inDays > 90;
  }

  @override
  List<Object?> get props => [
    foodId,
    nameEn,
    nameAr,
    aliases,
    category,
    per100g,
    portions,
    priceEgp,
    priceBasis,
    priceAsOf,
    updatedAt,
    createdAt,
    searchText,
  ];
}

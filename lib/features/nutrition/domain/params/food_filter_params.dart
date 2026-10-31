import 'package:equatable/equatable.dart';

class FoodFilterParams extends Equatable {
  final String? category;
  final int limit;
  final String? cursor;

  const FoodFilterParams({this.category, this.limit = 20, this.cursor});

  @override
  List<Object?> get props => [category, limit, cursor];
}

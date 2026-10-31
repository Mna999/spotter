part of 'food_search_bloc.dart';

abstract class FoodSearchEvent extends Equatable {
  const FoodSearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends FoodSearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class FoodSelected extends FoodSearchEvent {
  final String foodId;
  const FoodSelected(this.foodId);
  @override
  List<Object?> get props => [foodId];
}

class FoodListRequested extends FoodSearchEvent {
  final int limit;
  final String? cursor;
  const FoodListRequested({this.limit = 20, this.cursor});
  @override
  List<Object?> get props => [limit, cursor];
}

class CategoryFilterChanged extends FoodSearchEvent {
  final String? category;
  const CategoryFilterChanged(this.category);
  @override
  List<Object?> get props => [category];
}

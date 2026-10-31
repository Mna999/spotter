part of 'food_search_bloc.dart';

abstract class FoodSearchState extends Equatable {
  const FoodSearchState();
  @override
  List<Object?> get props => [];
}

class FoodSearchEmpty extends FoodSearchState {
  final String query;
  const FoodSearchEmpty({this.query = ''});
  @override
  List<Object?> get props => [query];
}

class FoodSearchLoading extends FoodSearchState {
  final String query;
  const FoodSearchLoading({this.query = ''});
  @override
  List<Object?> get props => [query];
}

class FoodSearchLoaded extends FoodSearchState {
  final List<FoodItem> foods;
  final FoodItem? selectedFood;
  final String query;
  const FoodSearchLoaded({
    required this.foods,
    this.selectedFood,
    this.query = '',
  });
  @override
  List<Object?> get props => [foods, selectedFood, query];
}

class FoodSearchError extends FoodSearchState {
  final String message;
  const FoodSearchError({required this.message});
  @override
  List<Object?> get props => [message];
}
